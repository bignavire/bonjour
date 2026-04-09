import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  final TextEditingController nameController =
      TextEditingController(text: "Jean Kouassi");

  final TextEditingController emailController =
      TextEditingController(text: "jean@email.com");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier profil"),
        backgroundColor: const Color(0xFFD85A30),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Nom",
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  "name": nameController.text,
                  "email": emailController.text,
                });
              },
              child: const Text("Enregistrer"),
            )
          ],
        ),
      ),
    );
  }
}


