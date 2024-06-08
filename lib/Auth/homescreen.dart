import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this line

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  File? _image;
  bool _isLoading = false;
  String? _profileImageUrl;
  final TextEditingController _todoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    if (user != null && user!.photoURL != null) {
      setState(() {
        _profileImageUrl = user!.photoURL!;
      });
    }
  }

  Future<void> _pickImage() async {
    setState(() {
      _isLoading = true;
    });

    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      await _uploadProfileImage();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _uploadProfileImage() async {
    if (_image == null || user == null) return;

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('profile_images')
        .child('${user!.uid}.jpg');

    await storageRef.putFile(_image!);
    final imageUrl = await storageRef.getDownloadURL();

    await user!.updatePhotoURL(imageUrl);
    await user!.reload();
    await _loadProfileImage();
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/auth');
  }

  Future<void> _addTodoItem(String task) async {
    if (task.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('todos')
        .add({'task': task, 'isCompleted': false});
  }

  Future<void> _deleteTodoItem(String id) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('todos')
        .doc(id)
        .delete();
  }

  Future<void> _toggleTodoItem(String id, bool isCompleted) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('todos')
        .doc(id)
        .update({'isCompleted': !isCompleted});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: _isLoading
                ? SpinKitCircle(color: Colors.white, size: 50.0)
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!)
                        : null,
                    child: _profileImageUrl == null
                        ? Icon(Icons.camera_alt,
                        size: 50, color: Colors.white)
                        : null,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Welcome, ${user?.email}!',
                  style: TextStyle(
                    color: Color.fromARGB(255, 93, 193, 218),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _todoController,
                    decoration: InputDecoration(
                      labelText: 'Add a new task',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          _addTodoItem(_todoController.text);
                          _todoController.clear();
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(user!.uid)
                        .collection('todos')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final todos = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: todos.length,
                        itemBuilder: (context, index) {
                          final todo = todos[index];
                          return ListTile(
                            title: Text(
                              todo['task'],
                              style: TextStyle(
                                decoration: todo['isCompleted']
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            leading: Checkbox(
                              value: todo['isCompleted'],
                              onChanged: (value) {
                                _toggleTodoItem(
                                    todo.id, todo['isCompleted']);
                              },
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _deleteTodoItem(todo.id);
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
