import 'dart:io';
// import 'package:flutter/foundation.dart';
import 'package:chatapp/models/UserModel.dart';
import 'package:chatapp/page/HomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class CompleteProfile extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const CompleteProfile(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  TextEditingController phone = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  File? imageFile;
  bool isLoading = false;

  Future<void> pickImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage == null) return;
      final imageTemp = File(pickedImage.path);
      setState(() => imageFile = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  void showPhotoOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Upload Profile Picture"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
                leading: const Icon(Icons.photo_album),
                title: const Text("Select from Gallery"),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
                leading: const Icon(Icons.camera_alt),
                title: const Text("Pick an Image"),
              ),
            ],
          ),
        );
      },
    );
  }

  void checkValues() {
    String fullname = fullNameController.text.trim();
    if (fullname == "" || imageFile == null || phone.text.trim() == "") {
      print("Please fill all the details");
    } else {
      setState(() {
        isLoading = true;
      });
      uploadData();
    }
  }

  void uploadData() async {
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilepictures")
        .child(widget.userModel.uid.toString())
        .putFile(imageFile!);

    TaskSnapshot snapshot = await uploadTask;
    String imageUrl = await snapshot.ref.getDownloadURL();
    String fullname = fullNameController.text.trim();
    String phoneno = phone.text.trim();

    widget.userModel.fullname = fullname;
    widget.userModel.profilepic = imageUrl;
    widget.userModel.phone = phoneno;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap())
        .then((value) {
      print("Data Uploaded");
      Navigator.popUntil(context, (route) => route.isFirst);

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return HomePage(
            userModel: widget.userModel, firebaseUser: widget.firebaseUser);
      }));
    }).catchError((error) {
      print("Failed to upload data: $error");
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text("Complete Profile"),
      ),
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ListView(
                  children: [
                    const SizedBox(height: 20),
                    CupertinoButton(
                      onPressed: showPhotoOptions,
                      child: CircleAvatar(
                        backgroundImage:
                            (imageFile != null) ? FileImage(imageFile!) : null,
                        radius: 60,
                        child: (imageFile == null)
                            ? const Icon(Icons.person, size: 60)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: fullNameController,
                      decoration: const InputDecoration(
                        labelText: "Full Name",
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: phone,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Phone No.",
                      ),
                    ),
                    const SizedBox(height: 40),
                    CupertinoButton(
                      color: Theme.of(context).colorScheme.secondary,
                      onPressed: checkValues,
                      child: const Text("Submit"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
