import 'package:chatapp/models/UserModel.dart';
import 'package:chatapp/page/CompleteProfilePage.dart';
import 'package:chatapp/page/LoginPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cpasswordController = TextEditingController();
  bool _isLoading = false;

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cpassword = cpasswordController.text.trim();

    if (email == "" || password == "" || cpassword == "") {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Invalid entries"),
          content: const Text("Please fill all the details"),
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
    } else if (password.length < 7 || cpassword.length < 7) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Weak Password"),
          content: const Text("Please create a password of minimum 8 letters"),
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
    } else if (password != cpassword) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Invalid Password"),
          content: const Text("Password did not match"),
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
      signup(email, password);
    }
  }

  void signup(String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      print(ex.code.toString());
    }

    setState(() {
      _isLoading = false;
    });

    if (credential != null) {
      // Then storing the credentials of the new user
      String uid = credential.user!.uid;
      UserModel newUser =
          UserModel(uid: uid, email: email, fullname: "", profilepic: "");
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newUser.toMap()) // set(data in the form of map)
          .then((value) {
        Navigator.popUntil(context, (route) => route.isFirst);

        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return CompleteProfile(
              userModel: newUser, firebaseUser: credential!.user!);
        }));
      });
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
                height: 10,
              ),
              TextField(
                controller: cpasswordController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: "Confirm Password"),
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
                      child: const Text("Sign Up")),
              const SizedBox(
                height: 10,
              ),
              Center(
                child: Row(
                  children: [
                    const Text("Already have an account ?"),
                    TextButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const LoginPage();
                          }));
                        },
                        child: const Text("Log In")),
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
