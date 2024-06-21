import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:untitled/card/CardListDetails.dart';

class CardListScreen extends StatefulWidget {
  @override
  _CardListScreenState createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // Количество вкладок
      child: Scaffold(
        appBar: AppBar(
          title: Text('Достопримечательности'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Монументы'),
              Tab(text: 'Музеи'),
              Tab(text: 'Театры'),
              Tab(text: 'Архитектура'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Поиск',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildCardList('Монументы'),
                  _buildCardList('Музеи'),
                  _buildCardList('Театры'),
                  _buildCardList('Архитектура'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardList(String category) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('items')
          .where('category', isEqualTo: category)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var cards = snapshot.data!.docs.where((doc) {
          final title = doc['title'].toString().toLowerCase();
          final searchQuery = _searchController.text.toLowerCase();
          return title.contains(searchQuery);
        }).toList();

        return ListView.builder(
          itemCount: cards.length,
          itemBuilder: (context, index) {
            var card = cards[index];
            return Card(
              elevation: 4,
              margin: EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CardDetailScreen(
                        title: card['title'],
                        description: card['description'],
                        location: card['location'],
                        imageUrl: List<String>.from(card['imageUrl']),
                        audioGuideUrl: card['audioGuideUrl'],
                        posterUrl: card.data().containsKey('posterUrl')
                            ? card['posterUrl']
                            : null,
                        category: card['category'],
                        latitude: card['latitude'],
                        longitude: card['longitude'],
                      ),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      child: Image.network(
                        card['imageUrl']
                            [0], // Отображаем первое изображение из списка
                        height: 200,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          return progress == null
                              ? child
                              : Center(child: CircularProgressIndicator());
                        },
                      ),
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        card['title'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
