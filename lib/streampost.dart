import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:olx/formatting.dart';
import 'package:olx/model.dart';
import 'package:olx/screens/post.dart';

import 'post_list_view.dart';

final db = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

class PostCard extends StatefulWidget {
  final PostItem postItem;

  const PostCard({Key? key, required this.postItem}) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = false; // Set initial value, or load from database
    checkIfPostIsFavorite();
  }

  Future<bool> isPostFavorite(String postId) async {
    // Implement your isPostFavorite logic here
    try {
      DocumentSnapshot userDoc = await db
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('favorites')
          .doc(_auth.currentUser!.uid)
          .get();

      if (userDoc.exists) {
        List<String> favoriteList =
            List<String>.from(userDoc.get('watchlist') as List<dynamic>? ?? []);
        return favoriteList.contains(postId);
      }
      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<void> toggleFavorites(String postId) async {
    // Implement your toggleFavorites logic here
    await _toggleFavorites(postId);
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  Future<void> checkIfPostIsFavorite() async {
    bool isPostLiked = await isPostFavorite(widget.postItem.postId);
    setState(() {
      isFavorite = isPostLiked;
    });
  }

  Future<void> _toggleFavorites(String postId) async {
    // Implement your toggleFavorites logic here
    try {
      DocumentReference userDocRef = db
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('favorites')
          .doc(_auth.currentUser!.uid);

      DocumentSnapshot userDoc = await userDocRef.get();

      if (!userDoc.exists) {
        await userDocRef.set({
          'watchlist': [postId],
        });
      } else {
        List<String> favoriteList =
            List<String>.from(userDoc.get('watchlist') as List<dynamic>? ?? []);

        if (favoriteList.contains(postId)) {
          favoriteList.remove(postId);
        } else {
          favoriteList.add(postId);
        }

        await userDocRef.update({
          'watchlist': favoriteList,
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Post(
                  postItem: widget.postItem,
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
                  widget.postItem.imageUrl[0],
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.postItem.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Builder(
                      builder: (context) {
                        return IconButton(
                          onPressed: () async {
                            await toggleFavorites(widget.postItem.postId);
                          },
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                          ),
                          color: isFavorite ? Colors.red : null,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  children: [
                    const Icon(Icons.attach_money),
                    const SizedBox(width: 6),
                    Text(
                      CurrencyFormat.convertToIdr(widget.postItem.price, 0),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  children: [
                    const Icon(Icons.location_on),
                    const SizedBox(width: 6),
                    Text(
                      widget.postItem.address,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  children: [
                    const Icon(Icons.date_range),
                    const SizedBox(width: 6),
                    Text(
                      CustomDateFormat.convertToDateTime(
                        widget.postItem.posteddate,
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StreamPost extends StatefulWidget {
  const StreamPost({Key? key});

  @override
  State<StreamPost> createState() => _StreamPostState();
}

class _StreamPostState extends State<StreamPost> {
  TextEditingController _searchController = TextEditingController();
  List<PostItem> _allPosts = [];
  List<PostItem> _filteredPosts = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  _onSearchChanged() {
    // Delay the execution of searchResultList by a short duration
    Future.delayed(Duration(milliseconds: 300), () {
      searchResultList();
    });
  }

  searchResultList() {
    var searchText = _searchController.text.toLowerCase();
    setState(() {
      _filteredPosts = _allPosts
          .where((post) =>
              post.title.toLowerCase().contains(searchText) ||
              post.description.toLowerCase().contains(searchText))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: db.collection('posts').snapshots(),
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

              _allPosts = snapshot.data!.docs.map<PostItem>((doc) {
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

              if (_filteredPosts.isEmpty) {
                // Show all posts if no search is performed
                _filteredPosts = List.from(_allPosts);
              }

              return PostListView(posts: _filteredPosts);
            },
          ),
        ),
      ],
    );
  }
}
