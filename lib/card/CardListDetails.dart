import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CardDetailScreen extends StatefulWidget {
  final String title;
  final String description;
  final String location;
  final List<String> imageUrl; // Список URL-адресов изображений
  final String audioGuideUrl;

  CardDetailScreen({
    required this.title,
    required this.description,
    required this.location,
    required this.imageUrl, // Изменено на список URL-адресов
    required this.audioGuideUrl,
  });

  @override
  _CardDetailScreenState createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  void _toggleAudio() {
    if (_isPlaying) {
      _player.stop();
    } else {
      _player.play(UrlSource(widget.audioGuideUrl));
    }

    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 400,
                enlargeCenterPage: true,
                enableInfiniteScroll: true,
                autoPlay: false,
              ),
              items: widget.imageUrl.map((imageUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PhotoViewScreen(imageUrl: imageUrl),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            return progress == null
                                ? child
                                : Center(child: CircularProgressIndicator());
                          },
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.description,
                style: TextStyle(fontSize: 18, height: 1.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Местоположение: ${widget.location}',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            if (widget.audioGuideUrl.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: _toggleAudio,
                  icon: Icon(_isPlaying ? Icons.stop : Icons.audiotrack),
                  label: Text(_isPlaying
                      ? 'Остановить аудиогид'
                      : 'Запустить аудиогид'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PhotoViewScreen extends StatelessWidget {
  final String imageUrl;

  PhotoViewScreen({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: PhotoView(
        imageProvider: NetworkImage(imageUrl),
      ),
    );
  }
}
