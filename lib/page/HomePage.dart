import 'package:chatapp/models/ChatRoomModel.dart';
import 'package:chatapp/models/FirebaseHelper.dart';
import 'package:chatapp/models/UserModel.dart';
import 'package:chatapp/page/ChatRoomPage.dart';
import 'package:chatapp/page/ProfilePage.dart';
import 'package:chatapp/page/SearchPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const HomePage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat App"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return ProfilePage(
                      firebaseUser: FirebaseAuth.instance.currentUser!);
                }));
              },
              icon: Icon(Icons.person_2_rounded)),
        ],
      ),
      body: SafeArea(
        child: Container(
            child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("chatrooms")
              .where("participants.${widget.userModel.uid}", isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                QuerySnapshot chatRoomSnapshot = snapshot.data as QuerySnapshot;
                return ListView.builder(
                    itemCount: chatRoomSnapshot.docs.length,
                    itemBuilder: (context, index) {
                      ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                          chatRoomSnapshot.docs[index].data()
                              as Map<String, dynamic>);
                      Map<String, dynamic> participants =
                          chatRoomModel.participants!;
                      List<String> participantKeys = participants.keys.toList();
                      participantKeys.remove(widget.userModel.uid);
                      return FutureBuilder(
                          future: Firebasehelper.getUserModelById(
                              participantKeys[0]),
                          builder: (context, userData) {
                            if (userData.connectionState ==
                                ConnectionState.done) {
                              if (userData.data != null) {
                                UserModel targetUser =
                                    userData.data as UserModel;
                                return ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return ChatRoomPage(
                                            chatroom: chatRoomModel,
                                            firebaseUser: widget.firebaseUser,
                                            userModel: widget.userModel,
                                            targetUser: targetUser,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        targetUser.profilepic.toString()),
                                  ),
                                  title: Text(targetUser.fullname.toString()),
                                  subtitle: (chatRoomModel.lastMessage
                                              .toString() !=
                                          "")
                                      ? Text(
                                          chatRoomModel.lastMessage.toString())
                                      : Text(
                                          "Say hi to your friend",
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontStyle: FontStyle.italic),
                                        ),
                                );
                              } else {
                                return Container();
                              }
                            } else {
                              return Container();
                            }
                          });
                    });
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              } else {
                return Center(
                  child: Text("No Chats found"),
                );
              }
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        )),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SearchPage(
                userModel: widget.userModel, firebaseUser: widget.firebaseUser);
          }));
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}
