import 'package:flutter/material.dart';
import 'package:olx/utils/model.dart';
import 'package:olx/screens/streampost.dart';

class PostListView extends StatelessWidget {
  final List<PostItem> posts;
  final bool gridview;

  const PostListView({super.key, required this.posts, required this.gridview});

  Future<void> _refresh() {
    return Future.delayed(const Duration(seconds: 3));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: (gridview)
                ? GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.5,
                    ),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return PostCard(
                        postItem: posts[index],
                        gridview: gridview,
                      );
                    },
                  )
                : ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return PostCard(
                        postItem: posts[index],
                        gridview: gridview,
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
