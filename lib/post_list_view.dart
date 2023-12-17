import 'package:flutter/material.dart';
import 'package:olx/model.dart';
import 'package:olx/streampost.dart';

class PostListView extends StatelessWidget {
  final List<PostItem> posts;

  const PostListView({Key? key, required this.posts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return PostCard(postItem: posts[index]);
      },
    );
  }
}
