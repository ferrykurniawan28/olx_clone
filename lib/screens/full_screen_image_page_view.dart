import 'package:flutter/material.dart';

class FullScreenImagePageView extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;
  const FullScreenImagePageView(
      {Key? key, required this.imageUrls, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        itemCount: imageUrls.length,
        controller: PageController(initialPage: initialIndex),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.pop(
                  context); // Pop back to the previous screen when tapped
            },
            child: Image.network(
              imageUrls[index],
              fit: BoxFit.contain,
              height: double.infinity,
              width: double.infinity,
              alignment: Alignment.center,
            ),
          );
        },
      ),
    );
  }
}
