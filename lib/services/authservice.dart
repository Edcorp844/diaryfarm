import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // User object getter
  User? get currentUser => _auth.currentUser;

  // Stream of user changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is signed in
  bool get isUserSignedIn => (currentUser != null);

  // Get user email (if signed in)
  String? get email => currentUser?.email;

  // Get username (if available, implement getUsername logic)
  String? get username => getUsername(currentUser);

  // Register a new user with Firebase Authentication
  Future<bool> register(String name, String email, String password, String utype, String? farmName) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      currentUser?.updateDisplayName(name);
       final userId = AuthService().currentUser?.uid;
      final docRef = FirebaseFirestore.instance.collection('users').doc(userId);
         await docRef.set({
            'UserName': name,
            'userId': userId,
            'userEmail': email,
            'userType': utype,
            'farmName': farmName ?? ''
             });          
      return true;
    } on FirebaseAuthException catch (e) {
       print(e.toString());
       return false;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Login a user with Firebase Authentication
  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
       print(e.toString());
       return false;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  // Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Example method to extract username from user object (replace with your logic)
  String getUsername(User? user) {
    if (user != null && user.displayName != null) {
      return user.displayName!;
    } else {
      return ""; // Or an alternative default username
    }
  }
}