import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:olx/Firebase_data.dart';
import 'package:olx/formatting.dart';
import 'package:olx/model.dart';
import 'package:olx/screens/post.dart';
// import 'package:olx/screens/post.dart';

final db = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

class StreamFavoritePost extends StatefulWidget {
  const StreamFavoritePost({Key? key});

  @override
  State<StreamFavoritePost> createState() => _StreamFavoritePostState();
}

class _StreamFavoritePostState extends State<StreamFavoritePost> {
  List<PostItem> watchlistPosts = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Fetch the user's watchlist
      DocumentSnapshot userDoc = await db
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('favorites')
          .doc(_auth.currentUser!.uid)
          .get();

      List<String> watchlistPostIds =
          List<String>.from(userDoc.get('watchlist') as List<dynamic>? ?? []);

      // Fetch data from the 'posts' collection for items in the watchlist
      QuerySnapshot snapshot = await db
          .collection('posts')
          .where('postID', whereIn: watchlistPostIds)
          .get();

      setState(() {
        // Map the 'posts' collection documents to PostItem objects
        watchlistPosts = snapshot.docs.map((doc) {
          return PostItem(
            username: doc['username'],
            email: doc['email'],
            title: doc['title'],
            price: doc['price'],
            posteddate: (doc['posteddate'] as Timestamp).toDate(),
            description: doc['description'],
            address: doc['address'],
            phoneNumber: doc['phoneNumber'],
            imageUrl: List<String>.from(doc['imageUrl']),
            postId: doc['postID'],
          );
        }).toList();
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: watchlistPosts.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Post(
                      postItem: watchlistPosts[index],
                    ),
                  ),
                );
              },
              contentPadding: const EdgeInsets.all(8),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.network(
                      watchlistPosts[index].imageUrl[0],
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          watchlistPosts[index].title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        favoriteButton(watchlistPosts, index),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      CurrencyFormat.convertToIdr(
                          watchlistPosts[index].price, 0),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      watchlistPosts[index].address,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      CustomDateFormat.convertToDateTime(
                          watchlistPosts[index].posteddate),
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconButton favoriteButton(List<PostItem> posts, int index) {
    return IconButton(
      onPressed: () async {
        await DatabaseFirestore().toggleFavorites(posts[index].postId);
        fetchData(); // Refresh the data after toggling favorites
      },
      icon: const Icon(
        Icons.favorite,
        color: Colors.red,
      ),
    );
  }
}
