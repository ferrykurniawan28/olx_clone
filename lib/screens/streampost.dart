import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:olx/utils/formatting.dart';
import 'package:olx/utils/model.dart';
import 'package:olx/screens/post.dart';

import 'post_list_view.dart';

final db = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

class PostCard extends StatefulWidget {
  final PostItem postItem;
  final bool gridview;

  const PostCard({
    super.key,
    required this.postItem,
    required this.gridview,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool isFavorite;
  final user = _auth.currentUser?.email;

  Future<void> _deletePost(String postId) async {
    try {
      QuerySnapshot snapshot =
          await db.collection('posts').where('postID', isEqualTo: postId).get();

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error deleting post: $e');
      throw e;
    }
  }

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
    return Card(
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
              height: (widget.gridview) ? 200 : 300,
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
                  Expanded(
                    child: Text(
                      widget.postItem.title,
                      style: TextStyle(
                        fontSize: (widget.gridview) ? 20 : 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Builder(
                        builder: (context) {
                          return IconButton(
                            onPressed: () async {
                              if (_auth.currentUser?.uid == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please login first.'),
                                  ),
                                );
                                return;
                              }
                              await toggleFavorites(widget.postItem.postId);
                            },
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                            ),
                            color: isFavorite ? Colors.red : null,
                          );
                        },
                      ),
                      if (user != null)
                        if (user!.contains('@admin'))
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Delete Post'),
                                    content: const Text(
                                        'Are you sure you want to delete this post?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () async {
                                          // await db
                                          //     .collection('posts')
                                          //     .doc( widget.postItem.postId)
                                          //     .delete();
                                          // Navigator.pop(context);
                                          try {
                                            await _deletePost(
                                                widget.postItem.postId);
                                            Navigator.pop(context);
                                          } catch (e) {
                                            print('Error deleting post: $e');
                                          }
                                        },
                                        child: const Text('Yes'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('No'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.delete_forever),
                          ),
                    ],
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
                    style: TextStyle(
                      fontSize: (widget.gridview) ? 15 : 17,
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
                    style: TextStyle(
                      fontSize: (widget.gridview) ? 15 : 17,
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
                    style: TextStyle(
                      fontSize: (widget.gridview) ? 15 : 17,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
  bool shortPrice = true;
  bool shortDate = true;
  bool gridview = true;

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
    Future.delayed(const Duration(milliseconds: 300), () {
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
          color: Colors.transparent,
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
        SizedBox(
          height: 55,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        shortPrice = !shortPrice;
                        if (shortPrice) {
                          _filteredPosts
                              .sort((a, b) => b.price.compareTo(a.price));
                        }
                        if (!shortPrice) {
                          _filteredPosts
                              .sort((a, b) => a.price.compareTo(b.price));
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black87,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          (shortPrice)
                              ? const Icon(
                                  Icons.arrow_upward,
                                  color: Colors.white,
                                )
                              : const Icon(
                                  Icons.arrow_downward,
                                  color: Colors.white,
                                ),
                          const SizedBox(width: 5),
                          const Text(
                            'Sort by Price',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        shortDate = !shortDate;
                        if (shortDate) {
                          _filteredPosts.sort(
                              (a, b) => b.posteddate.compareTo(a.posteddate));
                        }
                        if (!shortDate) {
                          _filteredPosts.sort(
                              (a, b) => a.posteddate.compareTo(b.posteddate));
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black87,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          (shortDate)
                              ? const Icon(
                                  Icons.arrow_upward,
                                  color: Colors.white,
                                )
                              : const Icon(
                                  Icons.arrow_downward,
                                  color: Colors.white,
                                ),
                          const SizedBox(width: 5),
                          const Text(
                            'Sort by Date',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 50,
                height: double.infinity,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      gridview = !gridview;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black87,
                    ),
                    child: Icon(
                      (gridview) ? Icons.grid_view : Icons.view_list_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        StreamBuilder<QuerySnapshot>(
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

            _allPosts.sort((a, b) => b.posteddate.compareTo(a.posteddate));

            if (_filteredPosts.isEmpty) {
              // Show all posts if no search is performed
              _filteredPosts = List.from(_allPosts);
            }

            return Expanded(
              child: PostListView(
                posts: _filteredPosts,
                gridview: gridview,
              ),
            );
          },
        ),
      ],
    );
  }
}
