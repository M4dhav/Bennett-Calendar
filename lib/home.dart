import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Bennett Calendar', style: TextStyle(fontSize: 16)),
          actions: [
            ElevatedButton(
              onPressed: () async {
                final GoogleSignInAccount? account =
                    await GoogleSignIn().signIn();
                if (account != null) {
                  print('Signed in as ${account.email}');
                } else {
                  print('Sign-in cancelled');
                }
              },
              child: const Text('Sign in with Google'),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text('Upload File'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
