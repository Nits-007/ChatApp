import 'package:chatapp/models/FirebaseHelper.dart';
import 'package:chatapp/models/UserModel.dart';
import 'package:chatapp/page/HomePage.dart';
import 'package:chatapp/page/LoginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBGby-MadFpiKg1gHn7kwfe4Jm343nquzI",
      appId: "1:1037221437406:android:aca83d602e74edaa05874f",
      messagingSenderId: "1037221437406",
      projectId: "chatapp-5a14f",
      authDomain: "chatapp-5a14f.firebaseapp.com",
      storageBucket: "chatapp-5a14f.appspot.com",
    ),
  );
  //Checking if user is already logged in
  User? currentUser = FirebaseAuth.instance
      .currentUser; //will return null if user not logged in else will return user
  if (currentUser != null) {
    //logged in
    UserModel? thisUserModel =
        await Firebasehelper.getUserModelById(currentUser.uid);
    if (thisUserModel != null) {
      runApp(
          MyAppLoggedIn(userModel: thisUserModel, firebaseUser: currentUser));
    } else {
      runApp(const MyApp());
    }
  } else {
    //not logged in
    runApp(const MyApp());
  }
}

//If not logged in
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: LoginPage());
  }
}

//If already logged in
class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MyAppLoggedIn(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(userModel: userModel, firebaseUser: firebaseUser),
    );
  }
}
