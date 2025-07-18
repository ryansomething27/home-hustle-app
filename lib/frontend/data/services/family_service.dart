import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user.dart';

class FamilyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get family data
  Future<Map<String, dynamic>> getFamily(String familyId) async {
    try {
      final doc = await _firestore
          .collection('families')
          .doc(familyId)
          .get();

      if (!doc.exists) {
        throw Exception('Family not found');
      }

      return {
        'id': doc.id,
        ...doc.data()!,
      };
    } catch (e) {
      throw Exception('Failed to get family: $e');
    }
  }

  // Get family members
  Future<List<UserModel>> getFamilyMembers(String familyId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('familyId', isEqualTo: familyId)
          .get();

      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Add the document ID
            return UserModel.fromJson(data as String);
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to get family members: $e');
    }
  }

  // Create a new family
  Future<Map<String, dynamic>> createFamily(String familyName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Not authenticated');
      }

      // Generate a unique invite code
      final inviteCode = _generateInviteCode();

      // Create family document
      final familyRef = await _firestore.collection('families').add({
        'name': familyName,
        'createdById': user.uid,
        'inviteCode': inviteCode,
        'memberCount': 1,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update user's familyId
      await _firestore.collection('users').doc(user.uid).update({
        'familyId': familyRef.id,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'id': familyRef.id,
        'name': familyName,
        'inviteCode': inviteCode,
      };
    } catch (e) {
      throw Exception('Failed to create family: $e');
    }
  }

  // Join existing family
  Future<Map<String, dynamic>> joinFamily(String inviteCode) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Not authenticated');
      }

      // Find family by invite code
      final snapshot = await _firestore
          .collection('families')
          .where('inviteCode', isEqualTo: inviteCode.toUpperCase())
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('Invalid invite code');
      }

      final familyDoc = snapshot.docs.first;
      final familyId = familyDoc.id;

      // Update user's familyId
      await _firestore.collection('users').doc(user.uid).update({
        'familyId': familyId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update family member count
      await _firestore.collection('families').doc(familyId).update({
        'memberCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'id': familyId,
        ...familyDoc.data(),
      };
    } catch (e) {
      throw Exception('Failed to join family: $e');
    }
  }

  // Leave family
  Future<void> leaveFamily() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Not authenticated');
      }

      // Get user's current family
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      final familyId = userData?['familyId'];

      if (familyId == null) {
        return;
      }

      // Remove familyId from user
      await _firestore.collection('users').doc(user.uid).update({
        'familyId': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update family member count
      await _firestore.collection('families').doc(familyId).update({
        'memberCount': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Check if family is empty and delete if needed
      final familyDoc = await _firestore.collection('families').doc(familyId).get();
      final memberCount = (familyDoc.data()?['memberCount'] as int?) ?? 0;
      
      if (memberCount <= 0) {
        await _firestore.collection('families').doc(familyId).delete();
      }
    } catch (e) {
      throw Exception('Failed to leave family: $e');
    }
  }

  // Remove family member (admin only)
  Future<void> removeFamilyMember(String memberId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Not authenticated');
      }

      // Get member's family
      final memberDoc = await _firestore.collection('users').doc(memberId).get();
      final memberData = memberDoc.data();
      final familyId = memberData?['familyId'];

      if (familyId == null) {
        return;
      }

      // Verify current user is family creator
      final familyDoc = await _firestore.collection('families').doc(familyId).get();
      final familyData = familyDoc.data();
      
      if (familyData?['createdById'] != user.uid) {
        throw Exception('Only family creator can remove members');
      }

      // Remove familyId from member
      await _firestore.collection('users').doc(memberId).update({
        'familyId': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update family member count
      await _firestore.collection('families').doc(familyId).update({
        'memberCount': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to remove family member: $e');
    }
  }

  // Generate new invite code
  Future<String> generateNewInviteCode() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Not authenticated');
      }

      // Get user's family
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      final familyId = userData?['familyId'];

      if (familyId == null) {
        throw Exception('No family found');
      }

      // Generate new code
      final newCode = _generateInviteCode();

      // Update family with new code
      await _firestore.collection('families').doc(familyId).update({
        'inviteCode': newCode,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return newCode;
    } catch (e) {
      throw Exception('Failed to generate new invite code: $e');
    }
  }

  // Update family name
  Future<void> updateFamilyName(String newName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Not authenticated');
      }

      // Get user's family
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      final familyId = userData?['familyId'];

      if (familyId == null) {
        throw Exception('No family found');
      }

      // Verify current user is family creator
      final familyDoc = await _firestore.collection('families').doc(familyId).get();
      final familyData = familyDoc.data();
      
      if (familyData?['createdById'] != user.uid) {
        throw Exception('Only family creator can update family name');
      }

      // Update family name
      await _firestore.collection('families').doc(familyId).update({
        'name': newName,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update family name: $e');
    }
  }

// Private helper to generate invite code
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    
    final buffer = StringBuffer();
    for (var i = 0; i < 6; i++) {
      buffer.write(chars[(random + i * 7) % chars.length]);
    }
    return buffer.toString();
  }
}