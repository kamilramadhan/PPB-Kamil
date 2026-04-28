import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/member_model.dart';
import '../models/division_model.dart';
import '../models/agenda_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ========== USER PROFILES ==========
  CollectionReference get _usersRef => _db.collection('users');

  Future<void> upsertUserProfile({
    required String uid,
    required String email,
    required String name,
    String? photoBase64,
  }) async {
    await _usersRef.doc(uid).set({
      'uid': uid,
      'email': email,
      'name': name,
      'photoBase64': photoBase64,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<Map<String, dynamic>?> streamUserProfile(String uid) {
    return _usersRef.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return doc.data() as Map<String, dynamic>;
    });
  }

  // ========== MEMBERS ==========
  CollectionReference get _membersRef => _db.collection('members');

  Future<void> addMember(MemberModel member) async {
    await _membersRef.add(member.toMap());
  }

  Future<void> updateMember(String id, MemberModel member) async {
    await _membersRef.doc(id).update(member.toMap());
  }

  Future<void> deleteMember(String id) async {
    await _membersRef.doc(id).delete();
  }

  Stream<List<MemberModel>> getMembers() {
    return _membersRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MemberModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  id: doc.id,
                ))
            .toList());
  }

  // ========== DIVISIONS ==========
  CollectionReference get _divisionsRef => _db.collection('divisions');

  Future<void> addDivision(DivisionModel division) async {
    await _divisionsRef.add(division.toMap());
  }

  Future<void> updateDivision(String id, DivisionModel division) async {
    await _divisionsRef.doc(id).update(division.toMap());
  }

  Future<void> deleteDivision(String id) async {
    await _divisionsRef.doc(id).delete();
  }

  Stream<List<DivisionModel>> getDivisions() {
    return _divisionsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DivisionModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  id: doc.id,
                ))
            .toList());
  }

  // ========== AGENDAS ==========
  CollectionReference get _agendasRef => _db.collection('agendas');

  Future<void> addAgenda(AgendaModel agenda) async {
    await _agendasRef.add(agenda.toMap());
  }

  Future<void> updateAgenda(String id, AgendaModel agenda) async {
    await _agendasRef.doc(id).update(agenda.toMap());
  }

  Future<void> deleteAgenda(String id) async {
    await _agendasRef.doc(id).delete();
  }

  Stream<List<AgendaModel>> getAgendas() {
    return _agendasRef
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AgendaModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                  id: doc.id,
                ))
            .toList());
  }

  // ========== DASHBOARD STATS ==========
  Future<Map<String, int>> getDashboardStats() async {
    final members = await _membersRef.get();
    final divisions = await _divisionsRef.get();
    final agendas = await _agendasRef.get();

    return {
      'members': members.docs.length,
      'divisions': divisions.docs.length,
      'agendas': agendas.docs.length,
    };
  }
}
