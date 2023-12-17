import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:olx/formatting.dart';
import 'package:olx/model.dart';
import 'package:olx/screens/asklogin.dart';
import 'package:olx/screens/post.dart';

final db = FirebaseFirestore.instance;

class StreamMyPost extends StatelessWidget {
  const StreamMyPost({super.key});

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // Handle the case when there is no authenticated user
      return AskLogin();
    }
    return StreamBuilder<QuerySnapshot>(
      stream: db
          .collection('posts')
          .where('email',
              isEqualTo: currentUser
                  .email) // Assuming 'userId' is a field in your posts collection storing the user ID
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No posts available.'),
          );
        }

        List<PostItem> posts = snapshot.data!.docs.map((doc) {
          return PostItem(
            postId: doc['postID'],
            username: doc['username'],
            email: doc['email'],
            title: doc['title'],
            price: doc['price'],
            posteddate: (doc['posteddate'] as Timestamp).toDate(),
            description: doc['description'],
            address: doc['address'],
            phoneNumber: doc['phoneNumber'],
            imageUrl: List<String>.from(doc['imageUrl']),
          );
        }).toList();

        return ListView.builder(
          itemCount: posts.length,
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
                          postItem: posts[index],
                        ),
                      ),
                    );
                  },
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
                          posts[index].imageUrl[0],
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        posts[index].title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        CurrencyFormat.convertToIdr(posts[index].price, 0),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        posts[index].address,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        CustomDateFormat.convertToDateTime(
                            posts[index].posteddate),
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
