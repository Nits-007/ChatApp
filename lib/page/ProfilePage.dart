import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp/models/UserModel.dart';
import 'package:chatapp/page/LoginPage.dart';

class ProfilePage extends StatefulWidget {
  final User firebaseUser;

  const ProfilePage({Key? key, required this.firebaseUser}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? userModel;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    String uid = widget.firebaseUser.uid;
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();
    setState(() {
      userModel = UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
    });
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> deleteProfile() async {
    String uid = widget.firebaseUser.uid;

    try {
      // Delete user document from Firestore
      await FirebaseFirestore.instance.collection("users").doc(uid).delete();

      // Delete user account from Firebase Authentication
      await widget.firebaseUser.delete();

      // Navigate back to login page after successful deletion
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print("Error deleting profile: $e");
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("Error"),
          content: Text("Failed to delete profile. Please try again."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(14),
                child: const Text("Okay"),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: userModel == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: NetworkImage(userModel!.profilepic ?? ""),
                  ),
                  SizedBox(height: 20),
                  Text(
                    userModel!.fullname ?? "",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    userModel!.email ?? "",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 20),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text("Full Name"),
                    subtitle: Text(userModel!.fullname ?? ""),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.call),
                    title: Text("Phone Number"),
                    subtitle: Text(userModel!.phone ?? ""),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.email),
                    title: Text("Email ID"),
                    subtitle: Text(userModel!.email ?? ""),
                  ),
                  SizedBox(height: 20),
                  // Logout Button
                  Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: ElevatedButton(
                      onPressed: signOut,
                      child: Text('Logout'),
                    ),
                  ),
                  // Delete Profile Button
                  ElevatedButton(
                    onPressed: deleteProfile,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text(
                      'Delete Profile',
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
