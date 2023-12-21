import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:olx/utils/Firebase_data.dart';
import 'package:olx/utils/formatting.dart';
import 'package:olx/utils/model.dart';

import 'full_screen_image_page_view.dart';

final _auth = FirebaseAuth.instance;

class Post extends StatefulWidget {
  final PostItem postItem;
  const Post({super.key, required this.postItem});

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  TextEditingController? titleController;
  TextEditingController? priceController;
  TextEditingController? descController;
  TextEditingController? addressController;
  TextEditingController? phoneController;
  bool isEdit = false;

  Future<void> _refresh() {
    return Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        titleController = TextEditingController(text: widget.postItem.title);
        priceController =
            TextEditingController(text: widget.postItem.price.toString());
        descController =
            TextEditingController(text: widget.postItem.description);
        addressController =
            TextEditingController(text: widget.postItem.address);
        phoneController =
            TextEditingController(text: widget.postItem.phoneNumber.toString());
      });
    });
  }

  @override
  void dispose() {
    titleController?.dispose();
    priceController?.dispose();
    descController?.dispose();
    addressController?.dispose();
    phoneController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    titleController = TextEditingController(text: widget.postItem.title);
    priceController =
        TextEditingController(text: widget.postItem.price.toString());
    descController = TextEditingController(text: widget.postItem.description);
    addressController = TextEditingController(text: widget.postItem.address);
    phoneController =
        TextEditingController(text: widget.postItem.phoneNumber.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bishop'),
        actions: [
          if (_auth.currentUser?.email == widget.postItem.email && !isEdit)
            IconButton(
              onPressed: () {
                setState(() {
                  isEdit = true;
                });
              },
              icon: const Icon(Icons.edit),
            ),
          if (_auth.currentUser?.email == widget.postItem.email && isEdit)
            IconButton(
              onPressed: () {
                setState(() {
                  isEdit = false;
                });
              },
              icon: const Icon(Icons.cancel),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
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
                    itemCount: widget.postItem.imageUrl.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenImagePageView(
                                imageUrls: widget.postItem.imageUrl,
                                initialIndex: index,
                              ),
                            ),
                          );
                        },
                        child: Image.network(
                          widget.postItem.imageUrl[index],
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: (!isEdit) ? 50 : 100,
                  width: double.infinity,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isEdit)
                              SizedBox(
                                width: 200,
                                child: TextField(
                                  controller: titleController,
                                ),
                              ),
                            if (isEdit)
                              SizedBox(
                                width: 200,
                                child: TextField(
                                  controller: priceController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    // hintText: widget.postItem.price.toString(),
                                    prefix: Text('Rp '),
                                  ),
                                ),
                              ),
                            if (!isEdit)
                              Text(
                                (widget.postItem.title),
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            if (!isEdit)
                              Text(
                                CurrencyFormat.convertToIdr(
                                    widget.postItem.price, 0),
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Column(
                              children: [
                                Text(
                                  CustomDateFormat.convertToDateTime(
                                      widget.postItem.posteddate),
                                  style: const TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
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
                      child: (!isEdit)
                          ? Text(widget.postItem.description)
                          : TextField(
                              controller: descController,
                              maxLines: null,
                              decoration: const InputDecoration(
                                  // hintText: 'Description',
                                  ),
                            ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.phone),
                          const SizedBox(
                            width: 6,
                          ),
                          if (isEdit)
                            SizedBox(
                              width: 150,
                              child: TextField(
                                controller: phoneController,
                                keyboardType: TextInputType.number,
                                // decoration: const InputDecoration(
                                //   // hintText: widget.postItem.phoneNumber,
                                //   // prefix: Text('+62 '),
                                // ),
                              ),
                            ),
                          if (!isEdit)
                            Text(
                              widget.postItem.phoneNumber,
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on),
                          const SizedBox(
                            width: 6,
                          ),
                          if (isEdit)
                            SizedBox(
                              width: 200,
                              child: TextField(
                                controller: addressController,
                                // decoration: const InputDecoration(
                                //   // hintText: widget.postItem.address,
                                // ),
                              ),
                            ),
                          if (!isEdit)
                            Text(
                              widget.postItem.address,
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isEdit)
                  GestureDetector(
                    onTap: () async {
                      try {
                        final price = int.parse(priceController!.text);
                        final post = PostItem(
                          postId: widget.postItem.postId,
                          username: widget.postItem.username,
                          email: widget.postItem.email,
                          title: titleController!.text,
                          price: price,
                          posteddate: widget.postItem.posteddate,
                          description: descController!.text,
                          address: addressController!.text,
                          phoneNumber: phoneController!.text,
                          imageUrl: widget.postItem.imageUrl,
                        );
                        DatabaseFirestore().editPostItem(post);
                        _refresh();

                        // Navigator.pop(context);
                        // Navigator.of(context).pushNamed('./create_post');
                        setState(() {
                          isEdit = false;
                        });
                      } catch (e) {
                        print(e);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 30,
                        width: double.infinity,
                        color: Colors.black87,
                        child: const Center(
                          child: Text(
                            'Update',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
