import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:gobind/common/common_const.dart';
import 'package:gobind/models/suggestion_model.dart';

class FirestoreService {
  static final FirestoreService _fireStoreRef = FirestoreService._internal();

  FirestoreService._internal();

  static final usersCollection = 'users';
  static final suggestions = 'users';

  factory FirestoreService() {
    return _fireStoreRef;
  }

  Future<bool> isAuthorized(User user) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection(usersCollection)
        .doc(user.uid)
        .get();
    if (snapshot.exists) return snapshot.data()['isAuthorized'];
    if (DEBUG) print('isAuthorized: User did not exist');
    return false;
  }

  Future<void> sendSuggestion(Suggestion suggestion) async {
    await FirebaseFirestore.instance
        .collection(suggestions)
        .doc()
        .set(suggestion.toJson());
  }
}
