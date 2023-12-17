import 'package:flutter/material.dart';
import 'package:olx/formatting.dart';
import 'package:olx/model.dart';

class Post extends StatelessWidget {
  final PostItem postItem;
  const Post({super.key, required this.postItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bishop'),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              height: 350,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(20),
              child: PageView.builder(
                itemCount: postItem.imageUrl.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImagePageView(
                            imageUrls: postItem.imageUrl,
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                    child: Image.network(
                      postItem.imageUrl[index],
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 10, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (postItem.title),
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            CurrencyFormat.convertToIdr(postItem.price, 0),
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Column(
                        children: [
                          Text(
                            CustomDateFormat.convertToDateTime(
                                postItem.posteddate),
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(20),
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(postItem.description),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: 90,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phone      :${postItem.phoneNumber}',
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'Address  :${postItem.address}',
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

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
