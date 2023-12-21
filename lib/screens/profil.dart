import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:olx/utils/Firebase_data.dart';
import 'package:olx/utils/formatting.dart';

final db = FirebaseFirestore.instance;
final _auth = FirebaseAuth.instance;

class Profile extends StatefulWidget {
  Profile({super.key, required this.onLoginStatusChanged});
  final void Function(bool) onLoginStatusChanged;

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  TextEditingController? controllerAddress;
  TextEditingController? controllerUsername;
  TextEditingController? controllerPhone;
  Map<String, dynamic>? data;
  String? username;
  String? email;
  File? _pickedImagefile;
  String? imageUrl;
  DateTime? memberSince;
  String? since;
  String? address;
  String? userName;
  int? phone;
  bool isUpload = false;
  int idx = 0;

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
  void dispose() {
    controllerAddress?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (idx == 0)
            IconButton(
              onPressed: () {
                setState(() {
                  idx = 1;
                });
              },
              icon: const Icon(Icons.edit),
            ),
          if (idx == 1)
            IconButton(
              onPressed: () {
                setState(() {
                  idx = 0;
                });
              },
              icon: const Icon(Icons.close),
            ),
        ],
      ),
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
            memberSince = data!['userSince'] ?? DateTime(2021);
            userName = data!['username'];
            phone = data?['phoneNumber'];
            since = CustomDateFormat.convertToMonthYear(memberSince!);
            address = data?['address'];
            controllerAddress = TextEditingController(text: address);
            controllerUsername = TextEditingController(text: userName);
            controllerPhone = TextEditingController(
                text: (phone != null) ? phone.toString() : null);

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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (idx == 1)
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: controllerUsername,
                                        decoration: const InputDecoration(
                                          labelText: 'Username',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(30),
                                            ),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter valid username';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    TextButton(
                                        onPressed: () {
                                          if (userName == null) {
                                            return;
                                          }
                                          DatabaseFirestore().uploadUsername(
                                              controllerUsername!.text);
                                          setState(() {
                                            idx = 0;
                                          });
                                        },
                                        child: const Text('Update')),
                                  ],
                                ),
                              if (idx == 0)
                                Text(
                                  username!,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              if (idx == 0)
                                Text(
                                  email!,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 8,
                        ),
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 6),
                        Text(
                          'Member Since: $since',
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 8,
                        ),
                        const Icon(Icons.location_on_rounded),
                        const SizedBox(
                          width: 6,
                        ),
                        if (idx == 1)
                          Expanded(
                            child: TextFormField(
                              // initialValue: (address != null) ? address : null,
                              controller: controllerAddress,
                              decoration: const InputDecoration(
                                labelText: 'Address',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(30),
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter valid address';
                                }
                                return null;
                              },
                            ),
                          ),
                        if (idx == 1)
                          TextButton(
                            onPressed: () {
                              if (controllerAddress!.text == null) {
                                return;
                              }
                              DatabaseFirestore()
                                  .uploadAddress(controllerAddress!.text);
                              setState(() {
                                idx = 0;
                              });
                            },
                            child: const Text('Add'),
                          ),
                        if (address == null && idx == 0)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                idx = 1;
                              });
                            },
                            child: const Text('Add Address'),
                          ),
                        if (address != null && idx == 0) Text(address!),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const SizedBox(width: 8),
                        const Icon(Icons.phone),
                        const SizedBox(width: 6),
                        if (idx == 0 && phone == null)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                idx = 1;
                              });
                            },
                            child: const Text('Add Phone'),
                          ),
                        if (idx == 1)
                          Expanded(
                            child: TextFormField(
                              controller: controllerPhone,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(30),
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter valid phone number';
                                }
                                return null;
                              },
                            ),
                          ),
                        if (idx == 1)
                          TextButton(
                            onPressed: () {
                              if (controllerPhone == null) {
                                return;
                              }
                              DatabaseFirestore().uploadPhone(
                                  int.parse(controllerPhone!.text));
                              setState(() {
                                idx = 0;
                              });
                            },
                            child: const Text('Add'),
                          ),
                        if (idx == 0 && phone != null)
                          Text(
                            phone.toString(),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: () {
                        FirebaseAuth.instance.signOut();
                        widget.onLoginStatusChanged(false);
                        Navigator.of(context).pushNamed('/login');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            // borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
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
