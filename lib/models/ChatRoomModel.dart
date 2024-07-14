import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  String? chatroomid;
  Map<String, dynamic>? participants; //ids of two user(in chat)
  String? lastMessage;
  DateTime? messagedon;

  ChatRoomModel(
      {this.chatroomid, this.participants, this.lastMessage, this.messagedon});

  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatroomid = map["chatroomid"];
    participants = map["participants"];
    lastMessage = map["lastMessage"];
    messagedon = (map["messagedon"] as Timestamp?)?.toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      "chatroomid": chatroomid,
      "participants": participants,
      "lastMessage": lastMessage,
      "messagedon": messagedon
    };
  }
}
