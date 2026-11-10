import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:revida/features/auth/domain/datasources/auth_datasource.dart';
import 'package:revida/features/auth/domain/entities/app_user.dart';

//Firebase authentication - Backend

class AuthDatasourceImpl extends AuthDatasource {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  /// Web OAuth client (`client_type` 3) from android/app/google-services.json.
  /// Android uses this as serverClientId so Firebase receives an ID token.
  /// The Android OAuth client (`client_type` 1) is created only after the
  /// signing SHA-1 is registered in the Firebase console.
  static const String _googleServerClientId =
      '380496289978-u7s3ch4k9nnlp5uoed223bh3v2ugplmc.apps.googleusercontent.com';

  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: const ['email'],
    serverClientId: _googleServerClientId,
  );

  //! Login
  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
      //attemp sign in
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      AppUser appUser = AppUser(uid: userCredential.user!.uid, email: email);

      return appUser;
    } catch (e) {
      throw Exception('Login failed $e');
    }
  }

  //! Register
  @override
  Future<AppUser?> registerWithEmailPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      await user?.updateDisplayName(name);

      AppUser appUser = AppUser(uid: userCredential.user!.uid, email: email);

      return appUser;
    } catch (e) {
      throw Exception('Registration failed $e');
    }
  }


  //!Delete Acount
  @override
  Future<void> deleteAccount() async {
    try {
      final user = firebaseAuth.currentUser;

      if(user == null) throw Exception('No user logged in...');

      await user.delete();

      await logout();
    } catch (e) {
      throw Exception('Failed to delete account $e');
    }
  }


  //! Get current user
  @override
  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;

    if (firebaseUser == null) return null;

    return AppUser(uid: firebaseUser.uid, email: firebaseUser.email!);
  }

  
  //! Logout
  @override
  Future<void> logout() async {
    await googleSignIn.signOut().catchError((Object _) => null);
    await firebaseAuth.signOut();
  }

  
  //! Reset password
  @override
  Future<String> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return 'Password reset email! Check your inbox.';
    } catch (e) {
      return 'An error ocurred $e';
    }
  }
  
  @override
  Future<AppUser?> signInWithGoogle() async {
    try {
      // A previous attempt can leave a Google session without an ID token.
      await googleSignIn.signOut().catchError((Object _) => null);

      final GoogleSignInAccount? gUser = await googleSignIn.signIn();

      // The account picker was closed without choosing an account.
      if (gUser == null) return null;

      final GoogleSignInAuthentication gAuth = await gUser.authentication;
      final String? idToken = gAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw Exception(
          'Google no entregó el ID token. Activa el proveedor Google en Firebase Authentication y registra el SHA-1 de tu keystore en la app Android de revida-bbadb.',
        );
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: idToken,
      );

      final UserCredential userCredential = await firebaseAuth
          .signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Firebase no devolvió un usuario de Google.');
      }

      return AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? gUser.email,
      );
    } on PlatformException catch (e) {
      throw Exception(_googleSignInMessage(e));
    }
  }

  String _googleSignInMessage(PlatformException error) {
    final String details =
        '${error.code} ${error.message ?? ''} ${error.details ?? ''}';
    if (details.contains('ApiException: 10')) {
      return 'Google rechazó la app (ApiException 10). En Firebase, proyecto revida-bbadb, agrega el SHA-1 y el SHA-256 de tu keystore en la app Android y vuelve a descargar google-services.json.';
    }
    if (error.code == GoogleSignIn.kNetworkError) {
      return 'Sin conexión al iniciar sesión con Google.';
    }
    return 'No se pudo iniciar sesión con Google: ${error.message ?? error.code}';
  }
  

}
