import 'package:firebase_auth/firebase_auth.dart';
import 'package:github_issue_tracker/core/strings.dart';

import '../core/api_status.dart';

class AuthenticationService {
  static Future signInWithGitHub() async {
    try {
      
      GithubAuthProvider githubProvider = GithubAuthProvider();
      final List<String> scopes = ["repo", "admin:org"];
      
      
      for (String scope in scopes) {
        githubProvider.addScope(scope);
      }
      
      
      UserCredential userCredential = await FirebaseAuth.instance.signInWithProvider(githubProvider);
      
      return Success(
        code: "200",
        response: userCredential,
      );
    } on FirebaseAuthException catch (e) {
      
      if (e.code == "unknown") {
        return Failure(
          code: "103",
          message: "${ApiResponseMessage.unknownError} in Firebase",
        );
      }
      return Failure(
        code: e.code,
        message: e.message ?? "An error occurred", 
      );
    } catch (e) {
      return Failure(
        code: "103",
        message: ApiResponseMessage.unknownError,
      );
    }
  }
}
