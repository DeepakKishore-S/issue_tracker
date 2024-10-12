import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_issue_tracker/service/authentication_service.dart';
import 'package:github_issue_tracker/view/issue_search_screen.dart';

import '../core/api_status.dart';
import '../core/strings.dart';

class LoginView extends ConsumerWidget {
  static const routeName = "/login_view";

  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SizedBox(
        width: double.maxFinite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            Image.asset(ImagesPath.githubLogo),
            const SizedBox(height: 100),
            Image.asset(ImagesPath.computer),
            const SizedBox(height: 20),
            const Text(
              "Let's build from here...",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            const Text(
              "Our platform drives innovation with tools that boost developer velocity",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: width * 0.8,
              height: height * 0.05,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  
                  final result = await AuthenticationService.signInWithGitHub();

                  if (result is Success) {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const IssueSearchScreen(),
                    ));
                  } else if (result is Failure) {
                    
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result.message)),
                    );
                  }
                },
                child: const Text("Sign in with GitHub"),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: width * 0.8,
              height: height * 0.05,
              child: TextButton(
                onPressed: () async {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const IssueSearchScreen(),
                  ));
                },
                child: const Text(
                  "Guest",
                ),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
