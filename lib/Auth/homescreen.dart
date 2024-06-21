import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = "Пользователь";
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _todoController = TextEditingController();
  List<Map<String, dynamic>> _todoList = [];

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadTodoList();
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? "Пользователь";
    });
  }

  Future<void> _saveUserName(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
  }

  Future<void> _loadTodoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? todoListString = prefs.getString('todoList');
    if (todoListString != null) {
      setState(() {
        _todoList = List<Map<String, dynamic>>.from(json.decode(todoListString));
      });
    }
  }

  Future<void> _saveTodoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('todoList', json.encode(_todoList));
  }

  void _addTodoItem(String task) {
    if (task.isEmpty) return;

    setState(() {
      _todoList.add({'task': task, 'isCompleted': false});
      _saveTodoList();
    });

    _todoController.clear();
  }

  void _deleteTodoItem(int index) {
    setState(() {
      _todoList.removeAt(index);
      _saveTodoList();
    });
  }

  void _toggleTodoItem(int index) {
    setState(() {
      _todoList[index]['isCompleted'] = !_todoList[index]['isCompleted'];
      _saveTodoList();
    });
  }

  void _updateUserName() {
    setState(() {
      _userName = _nameController.text;
      _saveUserName(_userName);
    });

    Navigator.of(context).pop();
  }

  void _showEditNameDialog() {
    _nameController.text = _userName;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Изменить имя'),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(hintText: "Введите ваше имя"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Отмена'),
            ),
            TextButton(
              onPressed: _updateUserName,
              child: Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed('/auth');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Домой'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _showEditNameDialog,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            SizedBox(height: 20),
            Text(
              'Добро пожаловать, $_userName!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _todoController,
                decoration: InputDecoration(
                  labelText: 'Добавить новую задачу',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      _addTodoItem(_todoController.text);
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _todoList.length,
                itemBuilder: (context, index) {
                  final todo = _todoList[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                    child: ListTile(
                      title: Text(
                        todo['task'],
                        style: TextStyle(
                          decoration: todo['isCompleted'] ? TextDecoration.lineThrough : TextDecoration.none,
                        ),
                      ),
                      leading: Checkbox(
                        value: todo['isCompleted'],
                        onChanged: (value) {
                          _toggleTodoItem(index);
                        },
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteTodoItem(index);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
