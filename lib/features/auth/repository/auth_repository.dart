import 'dart:ui' as html;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community/core/constants/firebase_constants.dart';
import 'package:community/core/constants/constants.dart';
import 'package:community/core/failure.dart';
import 'package:community/core/providers/firebase_providers.dart';
import 'package:community/core/type_defs.dart';
import 'package:community/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
      firestore: ref.read(firestoreProvider),
      auth: ref.read(authProvider),
      googleSignIn: ref.read(googleSignInProvider)),
);

final userIdProvider = StateProvider<String?>((ref) => null);

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  AuthRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
  })  : _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);

  Stream<User?> get authStateChange => _auth.authStateChanges();

  FutureEither<UserModel> signInWithGoogle(bool isFromLogin) async {
    try {
      UserCredential userCredential;
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider
            .addScope('https://www.googleapis.com/auth/contacts.readonly');
        googleProvider.setCustomParameters({'prompt': 'select_account'});

        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        if (googleUser == null) {
          return left(Failure("Google Sign-In was cancelled"));
        }

        final googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        if (isFromLogin) {
          userCredential = await _auth.signInWithCredential(credential);
        } else {
          userCredential =
              await _auth.currentUser!.linkWithCredential(credential);
        }
      }

      UserModel userModel;

      if (userCredential.additionalUserInfo!.isNewUser) {
        userModel = UserModel(
          name: userCredential.user!.displayName ?? 'No Name',
          profilePic: userCredential.user!.photoURL ?? Constants.avatarDefault,
          banner: Constants.bannerDefault,
          uid: userCredential.user!.uid,
          isAuthenticated: true,
          karma: 0,
          awards: [
            'awesomeAns',
            'gold',
            'platinum',
            'helpful',
            'plusone',
            'rocket',
            'thankyou',
            'til',
          ],
        );
        await _users.doc(userCredential.user!.uid).set(userModel.toMap());
      } else {
        userModel = await getUserData(userCredential.user!.uid).first;
      }
      return right(userModel);
    } on FirebaseAuthException catch (e) {
      return left(Failure(e.message ?? "Unknown Firebase error"));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<UserModel> signInAsGuest() async {
    try {
      var userCredential = await _auth.signInAnonymously();
      UserModel userModel = UserModel(
        name: 'Guest',
        profilePic: Constants.avatarDefault,
        banner: Constants.bannerDefault,
        uid: userCredential.user!.uid,
        isAuthenticated: false,
        karma: 0,
        awards: [
          'awesomeAns',
          'gold',
          'platinum',
          'helpful',
          'plusone',
          'rocket',
          'thankyou',
          'til',
        ],
      );
      await _users.doc(userCredential.user!.uid).set(userModel.toMap());

      return right(userModel);
    } on FirebaseAuthException catch (e) {
      return left(Failure(e.message ?? "Unknown Firebase error"));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<UserModel> getUserData(String uid) {
    return _users.doc(uid).snapshots().map(
          (event) => UserModel.fromMap(event.data() as Map<String, dynamic>),
        );
  }

  void logOut() async {
    if (!kIsWeb) {
      await _googleSignIn.signOut(); // Mobile
    }
    await _auth.signOut();

    // Force logout from Google session on web
    if (kIsWeb) {
      // Open Google's logout endpoint in a hidden iframe or new tab
      html.window.open("https://accounts.google.com/Logout", "_self");
    }
  }
}

extension on html.SingletonFlutterWindow {
  void open(String s, String t) {}
}
