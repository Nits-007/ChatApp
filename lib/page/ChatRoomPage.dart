import 'package:chatapp/main.dart';
import 'package:chatapp/models/ChatRoomModel.dart';
import 'package:chatapp/models/MessageModel.dart';
import 'package:chatapp/models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;

  const ChatRoomPage(
      {super.key,
      required this.targetUser,
      required this.chatroom,
      required this.userModel,
      required this.firebaseUser});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();

  void sendMessage() async {
    String msg = messageController.text.trim();
    if (msg.isNotEmpty) {
      // Send Message
      try {
        MessageModel newMessage = MessageModel(
          messageid: uuid.v1(),
          sender: widget.userModel.uid,
          createdon: DateTime.now(),
          text: msg,
          seen: false,
        );

        await FirebaseFirestore.instance
            .collection("chatrooms")
            .doc(widget.chatroom.chatroomid)
            .collection("messages")
            .doc(newMessage.messageid)
            .set(newMessage.toMap());

        widget.chatroom.lastMessage = msg;
        widget.chatroom.messagedon = DateTime.now();

        await FirebaseFirestore.instance
            .collection("chatrooms")
            .doc(widget.chatroom.chatroomid)
            .set(widget.chatroom.toMap());

        messageController.clear();
      } catch (e) {
        print("Error sending message: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage:
                  NetworkImage(widget.targetUser.profilepic.toString()),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(widget.targetUser.fullname.toString())
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("chatrooms")
                        .doc(widget.chatroom.chatroomid)
                        .collection("messages")
                        .orderBy("createdon", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasData) {
                          QuerySnapshot dataSnapshot =
                              snapshot.data as QuerySnapshot;
                          return ListView.builder(
                            reverse: true,
                            itemCount: dataSnapshot.docs.length,
                            itemBuilder: (context, index) {
                              MessageModel currentMessage =
                                  MessageModel.fromMap(
                                dataSnapshot.docs[index].data()
                                    as Map<String, dynamic>,
                              );
                              return Row(
                                mainAxisAlignment: (currentMessage.sender ==
                                        widget.userModel.uid)
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 10,
                                    ),
                                    margin: EdgeInsets.symmetric(vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (currentMessage.sender ==
                                              widget.userModel.uid)
                                          ? Colors.grey
                                          : Colors.green[700],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      currentMessage.text.toString(),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text("An error occurred. Please try later."),
                          );
                        } else {
                          return Center(
                            child: Text("Say Hi to your friend"),
                          );
                        }
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ),
              ),
              Container(
                color: Colors.grey[200],
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Row(
                  children: [
                    Flexible(
                      child: TextField(
                        controller: messageController,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: "Enter message",
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: sendMessage,
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
