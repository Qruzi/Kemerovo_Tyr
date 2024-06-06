import 'package:flutter/material.dart';
import 'package:untitled/navigation/feedback.dart';
import '../Auth/homescreen.dart';
import '../card/card_new.dart';
import 'map_screen.dart';

class NavigationScreen extends StatefulWidget {
  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    HomeScreen(),
    const MapScreen(),
    CardListScreen(),
    FeedbackPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home,color: Colors.blue,),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map,color: Colors.blue),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attractions,color: Colors.blue),
            label: 'Card',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback,color: Colors.blue),
            label: 'Feedback',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
