import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInApi {
  static final _googleSignIn = GoogleSignIn();

  static Future<GoogleSignInAccount?> login() => _googleSignIn.signIn();

  static Future logout() => _googleSignIn.signOut();

  static Future disconnect() => _googleSignIn.disconnect();

  // static Future clearAuth() => _googleSignIn.clearAuthenticatedUser();
}
