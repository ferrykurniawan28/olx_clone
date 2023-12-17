import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

final db = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

class Profile extends StatefulWidget {
  Profile({super.key, required this.onLoginStatusChanged});
  final void Function(bool) onLoginStatusChanged;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic>? data;
  String? username;
  String? email;
  File? _pickedImagefile;
  String? imageUrl;
  bool isUpload = false;

  void showPhotoOption(context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Photo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                setState(() {
                  isUpload = true;
                });
                final pickImage = await ImagePicker().pickImage(
                  source: ImageSource.camera,
                  imageQuality: 100,
                  maxWidth: 200,
                );
                if (pickImage == null) {
                  return;
                }
                if (pickImage != null) {
                  setState(() {
                    _pickedImagefile = File(pickImage.path);
                  });
                }
                final storageRef = FirebaseStorage.instance
                    .ref()
                    .child('user_images')
                    .child('${_auth.currentUser!.uid}.jpg');

                await storageRef.putFile(_pickedImagefile!);
                final imageUrl = await storageRef.getDownloadURL();
                // debugPrint(imageUrl);
                await db
                    .collection('users')
                    .doc(_auth.currentUser!.uid)
                    .update({"image": imageUrl});
                setState(() {
                  isUpload = false;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Gallery'),
              onTap: () async {
                setState(() {
                  isUpload = true;
                });
                final pickImage = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                );
                if (pickImage == null) {
                  return;
                }
                if (pickImage != null) {
                  setState(() {
                    _pickedImagefile = File(pickImage.path);
                  });
                  setState(() {
                    isUpload = false;
                  });
                }
                final storageRef = FirebaseStorage.instance
                    .ref()
                    .child('user_images')
                    .child('${_auth.currentUser!.uid}.jpg');

                await storageRef.putFile(_pickedImagefile!);
                final imageUrl = await storageRef.getDownloadURL();
                // debugPrint(imageUrl);
                await db
                    .collection('users')
                    .doc(_auth.currentUser!.uid)
                    .update({"image": imageUrl});
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_sweep_rounded),
              title: const Text('Delete Photo'),
              onTap: () {
                setState(() {
                  isUpload = true;
                });
                db
                    .collection('users')
                    .doc(_auth.currentUser!.uid)
                    .update({"image": null});
                setState(() {
                  isUpload = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<DocumentSnapshot>(
        future: db.collection('users').doc(_auth.currentUser!.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
              ],
            ));
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            data = snapshot.data!.data() as Map<String, dynamic>;

            username = data!['username'];
            email = data!['email'];
            imageUrl = data!['image'];

            return Center(
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        if (isUpload) const CircularProgressIndicator(),
                        if (!isUpload)
                          InkWell(
                            onTap: () {
                              showPhotoOption(context);
                            },
                            borderRadius: BorderRadius.circular(360),
                            child: CircleAvatar(
                              radius: 40,
                              foregroundImage: (imageUrl != null)
                                  ? NetworkImage(imageUrl!)
                                  : null,
                            ),
                          ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username!,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              email!,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: TextButton(
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                        widget.onLoginStatusChanged(false);
                        Navigator.of(context).pushNamed('/login');
                      },
                      child: const Text('Logout'),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
