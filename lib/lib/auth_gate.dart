import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gotime/pages/login/loginpage.dart';
import 'package:gotime/pages/pageaccueil.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        
        debugPrint("ConnectionState: ${snapshot.connectionState}");
        debugPrint("HasData: ${snapshot.hasData}");
        debugPrint("Error: ${snapshot.error}");

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Chargement..."),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text("Erreur : ${snapshot.error}"),
            ),
          );
        }

        if (snapshot.hasData) {
          return const Pageaccueil();
        }

        return const Loginpage();
      },
    );
  }
}