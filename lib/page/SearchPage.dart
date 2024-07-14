import 'package:chatapp/main.dart';
import 'package:chatapp/models/ChatRoomModel.dart';
import 'package:chatapp/models/UserModel.dart';
import 'package:chatapp/page/ChatRoomPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchPage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController nameSearchController = TextEditingController();
  TextEditingController phoneSearchController = TextEditingController();

  Future<ChatRoomModel?> getChatRoomModel(UserModel targetUser) async {
    ChatRoomModel? chatroom;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();
    if (snapshot.docs.isNotEmpty) {
      // Fetch the existing one
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);
      chatroom = existingChatroom;
    } else {
      // Create a new one
      ChatRoomModel newChatroom = ChatRoomModel(
          chatroomid: uuid.v1(),
          lastMessage: "",
          participants: {
            widget.userModel.uid.toString(): true,
            targetUser.uid.toString(): true
          });
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatroom.chatroomid)
          .set(newChatroom.toMap());
      chatroom = newChatroom;
    }
    return chatroom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              child: Column(
                children: [
                  TextField(
                    controller: nameSearchController,
                    decoration: const InputDecoration(labelText: "Full Name"),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: phoneSearchController,
                    decoration: const InputDecoration(labelText: "Phone No."),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CupertinoButton(
                      child: const Text("Search"),
                      onPressed: () {
                        setState(() {});
                      }),
                  StreamBuilder(
                      stream: (nameSearchController.text.isNotEmpty)
                          ? FirebaseFirestore.instance
                              .collection("users")
                              .where("fullname",
                                  isEqualTo: nameSearchController.text)
                              .where("fullname",
                                  isNotEqualTo: widget.userModel.fullname)
                              .snapshots()
                          : FirebaseFirestore.instance
                              .collection("users")
                              .where("phone",
                                  isEqualTo: phoneSearchController.text)
                              .where("phone",
                                  isNotEqualTo: widget.userModel.phone)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.active) {
                          if (snapshot.hasData) {
                            QuerySnapshot dataSnapshot =
                                snapshot.data as QuerySnapshot;
                            if (dataSnapshot.docs.isNotEmpty) {
                              return Expanded(
                                child: ListView.builder(
                                  itemCount: dataSnapshot.docs.length,
                                  itemBuilder: (context, index) {
                                    Map<String, dynamic> userMap =
                                        dataSnapshot.docs[index].data()
                                            as Map<String, dynamic>;
                                    UserModel searchedUser =
                                        UserModel.fromMap(userMap);
                                    return ListTile(
                                      onTap: () async {
                                        ChatRoomModel? chatRoomModel =
                                            await getChatRoomModel(
                                                searchedUser);
                                        if (chatRoomModel != null) {
                                          Navigator.pop(context);
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return ChatRoomPage(
                                              targetUser: searchedUser,
                                              chatroom: chatRoomModel,
                                              userModel: widget.userModel,
                                              firebaseUser: widget.firebaseUser,
                                            );
                                          }));
                                        }
                                      },
                                      leading: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            searchedUser.profilepic!),
                                      ),
                                      title: Text(
                                          searchedUser.fullname.toString()),
                                      subtitle:
                                          Text(searchedUser.email.toString()),
                                    );
                                  },
                                ),
                              );
                            } else {
                              return const Text("No results found");
                            }
                          } else if (snapshot.hasError) {
                            return const Text("An error occurred");
                          } else {
                            return const Text("No results found");
                          }
                        } else {
                          return const CircularProgressIndicator();
                        }
                      })
                ],
              ))),
    );
  }
}
