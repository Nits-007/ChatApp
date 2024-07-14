class UserModel {
  String? uid;
  String? fullname;
  String? email;
  String? profilepic;
  String? phone;

  UserModel({this.uid, this.fullname, this.email, this.profilepic, this.phone});

  UserModel.fromMap(Map<String, dynamic> map) {
    //from Map Constructor=>Map to Object
    uid = map["uid"];
    fullname = map["fullname"];
    email = map["email"];
    profilepic = map["profilepic"];
    phone = map["phone"];
  }

  Map<String, dynamic> toMap() {
    //to map function => returns map from object
    return {
      "uid": uid,
      "fullname": fullname,
      "email": email,
      "profilepic": profilepic,
      "phone": phone
    };
  }
}
