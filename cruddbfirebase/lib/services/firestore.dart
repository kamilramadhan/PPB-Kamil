import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  CollectionReference<Map<String, dynamic>> _userNotesCollection() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'User belum login.',
      );
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notes');
  }

  // create new note
  Future<void> addNote(
    String title,
    String content,
    DateTime tgl,
    String label,
  ) {
    final notes = _userNotesCollection();
    return notes.add({
      'title': title,
      'content': content,
      'tgl': Timestamp.fromDate(tgl),
      'label': label,
      'createdAt': Timestamp.now(),
    });
  }

  // fetch all notes for current user
  Stream<QuerySnapshot> getNotes() {
    final notes = _userNotesCollection();
    return notes.orderBy('createdAt', descending: true).snapshots();
  }

  // update notes
  Future<void> updateNote(
    String id,
    String title,
    String content,
    DateTime tgl,
    String label,
  ) {
    final notes = _userNotesCollection();
    return notes.doc(id).update({
      'title': title,
      'content': content,
      'tgl': Timestamp.fromDate(tgl),
      'label': label,
      'updatedAt': Timestamp.now(),
    });
  }

  // delete notes
  Future<void> deleteNote(String id) {
    final notes = _userNotesCollection();
    return notes.doc(id).delete();
  }
}