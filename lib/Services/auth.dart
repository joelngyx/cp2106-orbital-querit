import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:orbital_2020_usono_my_ver/Models/User.dart';
import 'package:orbital_2020_usono_my_ver/Services/database/UserDbService.dart';

class AuthService {
 
  final FirebaseAuth _auth = FirebaseAuth
      .instance; // via this object, we call different Firebase_Auth methods
  

  // Anonymously signing in
  Future signInAnon() async {
    try {
      AuthResult result = await _auth.signInAnonymously();
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  User _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(user.uid) : null;
  }

  Stream<User> get user {
    return _auth.onAuthStateChanged.map(_userFromFirebaseUser);
  }

  // sign in with email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // register with email and password
  Future registerWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email,
          password:
              password); // when successful, it signs the user into the app and thus updates the onAuthStateChanged stream
      FirebaseUser user = result.user;

      // create a new document for the user, with its uid
      await UserDbService(uid: user.uid).updateUserData(name);

      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign out
  Future signOut() async {


    FirebaseUser user = await _auth.currentUser();
    if (user.email == null) {
        user.delete();
        Firestore.instance.collection('Users').document(user.uid).delete(); // deletes anon users upon logout from firestore
    } else {
        return await _auth.signOut();
    }

  }
}




