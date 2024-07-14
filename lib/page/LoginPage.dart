import 'package:chatapp/models/UserModel.dart';
import 'package:chatapp/page/HomePage.dart';
import 'package:chatapp/page/SignUpPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    // Regular expression for validating an email address
    RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (email.isEmpty || password.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("Invalid entries"),
          content: Text("Please fill all the details"),
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
    } else if (!emailRegex.hasMatch(email)) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("Invalid Email"),
          content: Text("Please enter a valid email address"),
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
    } else if (password.length < 8) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("Weak Password"),
          content: Text("Please enter a password of minimum 8 characters"),
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
    } else {
      login(email, password);
    }
  }

  void login(String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    UserCredential? credential;

    try {
      credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // After successful login, fetch user data from Firestore
      String uid = credential.user!.uid;
      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();

      // Convert Firestore data into UserModel
      UserModel userModel =
          UserModel.fromMap(userData.data() as Map<String, dynamic>);

      // Navigate to home page upon successful login
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return HomePage(userModel: userModel, firebaseUser: credential!.user!);
      }));
    } on FirebaseAuthException catch (ex) {
      setState(() {
        _isLoading = false;
      });

      String errorMessage = "An error occurred, please try again.";

      if (ex.code == 'user-not-found') {
        errorMessage =
            "No user found with this email. Please check the email and try again.";
      } else if (ex.code == 'wrong-password') {
        errorMessage =
            "Invalid password. Please check your password and try again.";
      }

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("Login Failed"),
          content: Text(errorMessage),
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
    } catch (e) {
      print("Error during login: $e");
      setState(() {
        _isLoading = false;
      });

      // Show a generic error dialog
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("Login Failed"),
          content:
              Text("An unexpected error occurred. Please try again later."),
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
      body: SafeArea(
          child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Center(
          child: SingleChildScrollView(
              child: Column(
            children: [
              Text(
                "Chat App",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 40,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email Address"),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
              ),
              const SizedBox(
                height: 50,
              ),
              _isLoading
                  ? CircularProgressIndicator()
                  : CupertinoButton(
                      color: Theme.of(context).colorScheme.secondary,
                      onPressed: () {
                        checkValues();
                      },
                      child: const Text("Log In")),
              const SizedBox(
                height: 10,
              ),
              Center(
                child: Row(
                  children: [
                    const Text("Dont have an account ?"),
                    TextButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const SignUpPage();
                          }));
                        },
                        child: const Text("Sign Up")),
                  ],
                ),
              )
            ],
          )),
        ),
      )),
    );
  }
}
