import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String? category;
  final String? title;
  final String? body;
  final String? created;
  final String? lastUpdate;

  NoteModel(
      {this.category, this.title, this.body, this.created, this.lastUpdate});

  factory NoteModel.fromSnapshot(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return NoteModel(
        category: snapshot['category'],
        title: snapshot['title'],
        body: snapshot['body'],
        created: snapshot['created'],
        lastUpdate: snapshot['lastUpdate']);
  }

  Map<String, dynamic> toJson() => {
        "category": category,
        "title": title,
        "body": body,
        "created": created,
        "lastUpdate": lastUpdate,
      };
}
