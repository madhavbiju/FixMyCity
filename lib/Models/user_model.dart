class UserModel {
  String? uid;
  String? email;
  String? firstName;
  String? secondName;
  bool? isVerified;

  UserModel(
      {this.uid, this.email, this.firstName, this.secondName, this.isVerified});

  // receiving data from server
  factory UserModel.fromMap(map) {
    return UserModel(
        uid: map['uid'],
        email: map['email'],
        firstName: map['firstName'],
        secondName: map['secondName'],
        isVerified: map['isVerified']);
  }

  // sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'secondName': secondName,
      'isVerified': isVerified,
    };
  }
}
