import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:olx/favorite.dart';
import 'package:olx/screens/asklogin.dart';
import 'package:olx/screens/createpost.dart';
import 'package:olx/screens/mypost.dart';
import 'package:olx/streampost.dart';

final db = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

class Home extends StatefulWidget {
  const Home(
      {required this.login, required this.onLoginStatusChanged, super.key});
  final bool login;
  final void Function(bool) onLoginStatusChanged;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  Map<String, dynamic>? data;
  String? imageUrl;
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      DocumentSnapshot snapshot =
          await db.collection('users').doc(_auth.currentUser!.uid).get();

      if (snapshot.exists) {
        setState(() {
          data = snapshot.data() as Map<String, dynamic>;
          imageUrl = data?['image'];
        });
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bishop'),
        actions: [
          if (widget.login)
            InkWell(
              onTap: () {
                Navigator.of(context).pushNamed('/profile');
              },
              borderRadius: BorderRadius.circular(360),
              child: CircleAvatar(
                backgroundImage:
                    (imageUrl != null) ? NetworkImage(imageUrl!) : null,
              ),
            ),
          if (!widget.login)
            IconButton(
              onPressed: () {
                if (widget.login == true) {
                  FirebaseAuth.instance.signOut();
                }
                widget.onLoginStatusChanged(false);
                Navigator.of(context).pushNamed('/login');
              },
              icon: const Icon(Icons.logout),
            ),
        ],
        automaticallyImplyLeading: false,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Center(
        child: Column(
          children: [
            if (_selectedIndex == 0)
              const Expanded(
                child: StreamPost(),
              ),
            if (_selectedIndex == 1)
              if (!widget.login)
                const Expanded(
                  child: AskLogin(),
                )
              else if (widget.login)
                const Expanded(
                  child: CreatePost(),
                ),
            if (_selectedIndex == 2)
              const Expanded(
                child: StreamMyPost(),
              ),
            if (_selectedIndex == 3)
              const Expanded(
                child: StreamFavoritePost(),
              ),
          ],
        ),
      ),
      // backgroundColor: Colors.deepPurple,
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.black,
        onTap: _onItemTapped,
        items: const [
          Icon(Icons.home),
          Icon(Icons.add),
          Icon(Icons.post_add),
          Icon(Icons.favorite),
        ],
      ),
    );
  }
}
