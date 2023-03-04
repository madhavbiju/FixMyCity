import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fixmycity/Models/cont_model.dart';
import 'package:fixmycity/Screens/login.dart';

class FirestoreHelper {
  static Stream<List<NoteModel>> read() {
    final noteCollection = FirebaseFirestore.instance
        .collection("user-notes")
        .doc(gUid)
        .collection('notes');
    return noteCollection.snapshots().map((querySnapshot) =>
        querySnapshot.docs.map((e) => NoteModel.fromSnapshot(e)).toList());
  }

  static Future create(NoteModel note) async {
    final contCollection = FirebaseFirestore.instance.collection("user-notes");
    final docRef = contCollection.doc(gUid);
    final subCollectionRef = docRef.collection('notes');
    final newNote = NoteModel(
            category: note.category,
            title: note.title,
            body: note.body,
            created: note.created,
            lastUpdate: note.lastUpdate)
        .toJson();

    try {
      await subCollectionRef.add(newNote);
    } catch (e) {
      print("some error occurred $e");
    }
  }

  static Future update(NoteModel note) async {
    final noteCollection = FirebaseFirestore.instance.collection("user-notes");
    final docRef = noteCollection.doc(gUid);
    final subCollectionRef = docRef.collection('notes');
    final newNote = NoteModel(
            category: note.category,
            title: note.title,
            body: note.body,
            created: note.created,
            lastUpdate: note.lastUpdate)
        .toJson();

    try {
      await subCollectionRef.doc(note.category).update(newNote);
    } catch (e) {
      print("some error occurred $e");
    }
  }

  static Future delete(NoteModel note) async {
    final noteCollection = FirebaseFirestore.instance.collection("user-notes");
    final docRef = noteCollection.doc(gUid);
    final subCollectionRef = docRef.collection('notes');
    try {
      await subCollectionRef.doc(note.category).delete();
    } catch (e) {
      print("some error occurred $e");
    }
  }
}
