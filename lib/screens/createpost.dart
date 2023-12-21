import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:olx/utils/Firebase_data.dart';
import 'package:olx/utils/model.dart';
import 'package:olx/screens/full_screen_image_page_view.dart';
import 'package:olx/screens/home.dart';
import 'package:uuid/uuid.dart';

final db = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  String userId = _auth.currentUser!.uid;
  List<String> images = [];
  // List<String?> localImagePaths = List.generate(1, (index) => null);
  File? _pickedImagefile;
  String? _username;
  String? _loc;
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  TextEditingController _location = TextEditingController();
  TextEditingController _contact = TextEditingController();
  int idx = 1;
  int max = 5;
  List<String> items = List.generate(1, (index) => 'Item $index');

  final docRef = db.collection('users').doc(_auth.currentUser!.uid);

  @override
  void initState() {
    docRef.get().then((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      setState(() {
        _username = data['username'];
        // _loc = data['address'];
        _location = TextEditingController(
          text: data['address'],
        );
        final int phone = data['phoneNumber'];
        _contact = TextEditingController(
          text: phone.toString(),
        );
      });
      print(data);
    });
    super.initState();
  }

  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();

    List<String> imageUrlList = [];

    try {
      final int price = int.parse(_price.text);
      Uuid uuid = const Uuid();
      String postId = uuid.v4();
      final post = PostItem(
        postId: postId,
        username: _username!,
        email: _auth.currentUser!.email!,
        title: _title.text,
        price: price,
        posteddate: DateTime.now(),
        description: _description.text,
        address: _location.text,
        phoneNumber: _contact.text,
        imageUrl: images,
      );

      DatabaseFirestore().addPostItem(
        post,
      );
    } catch (e) {
      debugPrint(e.toString());
    }

    Navigator.of(context).pushNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: Form(
            key: _formKey,
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'Create Post',
                  style: TextStyle(
                    fontSize: 20,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.all(20),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                              // borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey)),
                          child: GestureDetector(
                            child: (index == items.length - 1)
                                ? const Center(child: Icon(Icons.add_a_photo))
                                : Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Container(
                                        width: 250,
                                        height: 250,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          // border: Border.all(color: Colors.grey),
                                        ),
                                        child: Image.network(
                                          images[index],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          setState(() {
                                            images.removeAt(index);
                                            items.removeAt(index);
                                            idx--;
                                          });
                                          // await images[index]
                                        },
                                        icon: const Icon(Icons.close),
                                      ),
                                    ],
                                  ),
                            onTap: () {
                              if (index == items.length - 1) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Choose Image'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                    ],
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: const Icon(Icons.camera),
                                          title: const Text('Camera'),
                                          onTap: () async {
                                            final pickImage =
                                                await ImagePicker().pickImage(
                                              source: ImageSource.camera,
                                            );
                                            if (pickImage == null) {
                                              return;
                                            }
                                            if (pickImage != null) {
                                              setState(() {
                                                _pickedImagefile =
                                                    File(pickImage.path);
                                              });
                                            }
                                            final storageRef = FirebaseStorage
                                                .instance
                                                .ref()
                                                .child('post_images')
                                                .child(
                                                    '${_auth.currentUser!.uid}')
                                                .child(
                                                    '${_auth.currentUser!.uid}${DateTime.now()}_.jpg');

                                            await storageRef
                                                .putFile(_pickedImagefile!);
                                            final imageUrl = await storageRef
                                                .getDownloadURL();
                                            images.add(imageUrl);
                                            if (pickImage != null) {
                                              setState(() {
                                                _pickedImagefile =
                                                    File(pickImage.path);
                                              });
                                            }

                                            Navigator.pop(context);
                                            if (index == items.length - 1 &&
                                                items.length <= max) {
                                              setState(() {
                                                items.add('Item $idx');
                                                idx++;
                                              });
                                            }
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.image),
                                          title: const Text('Gallery'),
                                          onTap: () async {
                                            final pickImage =
                                                await ImagePicker().pickImage(
                                              source: ImageSource.gallery,
                                            );
                                            if (pickImage == null) {
                                              return;
                                            }
                                            if (pickImage != null) {
                                              setState(() {
                                                _pickedImagefile =
                                                    File(pickImage.path);
                                              });
                                            }
                                            final storageRef = FirebaseStorage
                                                .instance
                                                .ref()
                                                .child('post_images')
                                                .child(
                                                    '${_auth.currentUser!.uid}')
                                                .child(
                                                    '${_auth.currentUser!.uid}${DateTime.now()}_.jpg');

                                            await storageRef
                                                .putFile(_pickedImagefile!);
                                            final imageUrl = await storageRef
                                                .getDownloadURL();
                                            images.add(imageUrl);
                                            if (pickImage != null) {
                                              setState(() {
                                                _pickedImagefile =
                                                    File(pickImage.path);
                                              });
                                            }
                                            Navigator.pop(context);
                                            if (index == items.length - 1 &&
                                                items.length <= max) {
                                              setState(() {
                                                items.add('Item $idx');
                                                idx++;
                                              });
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FullScreenImagePageView(
                                      imageUrls: images,
                                      initialIndex: index,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(20),
                  child: TextFormField(
                    controller: _title,
                    maxLength: 20,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter title';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      // border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(20),
                  // decoration: BoxDecoration(
                  //   border: Border.all(
                  //     color: Colors.grey,
                  //   ),
                  //   borderRadius: BorderRadius.circular(10),
                  // ),
                  child: IntrinsicHeight(
                    child: TextFormField(
                      controller: _description,
                      keyboardType: TextInputType.multiline,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter description';
                        }
                        return null;
                      },
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(20),
                  child: TextFormField(
                    controller: _price,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter price';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      icon: Icon(Icons.monetization_on_outlined),
                      prefix: Text('RP '),
                      labelText: 'Price',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(20),
                  child: TextFormField(
                    controller: _location,
                    // initialValue: _loc,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter location';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      icon: Icon(Icons.location_on),
                      labelText: 'Location',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(20),
                  child: TextFormField(
                    controller: _contact,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter contact';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      icon: Icon(Icons.phone),
                      labelText: 'Contact',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(20),
                  child: GestureDetector(
                    onTap: _submit,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      width: double.infinity,
                      color: Colors.black87,
                      child: const Center(
                        child: Text(
                          'Upload',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
