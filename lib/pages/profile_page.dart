import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gotime/pages/edit_profile_page.dart';
import 'package:gotime/lib/models/user_preferences.dart';
import 'package:gotime/main.dart';
import 'package:gotime/pages/edit_preferences_page.dart';
import 'package:gotime/notifications_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<String> _categories = [];
  String _budget = '';
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _loadPhoto();
  }

  Future<void> _loadPrefs() async {
    final prefs = await UserPreferences.load();
    setState(() {
      _categories = prefs.categories;
      _budget = prefs.budget;
    });
  }

  Future<void> _loadPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_photo_path');
    if (path != null && File(path).existsSync()) {
      setState(() => _photoPath = path);
    }
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Changer la photo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _PhotoSourceButton(
                  icon: Icons.camera_alt,
                  label: 'Caméra',
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
                _PhotoSourceButton(
                  icon: Icons.photo_library,
                  label: 'Galerie',
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );

    if (source == null) return;

    await Future.delayed(const Duration(milliseconds: 300));

    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 75,
      maxWidth: 512,
    );

    if (image == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_photo_path', image.path);

    if (mounted) {
      setState(() => _photoPath = image.path);
    }
  }

  String get _budgetLabel {
    if (_budget == 'gratuit') return '🆓 Gratuit';
    if (_budget == 'moyen') return '💰 Moyen';
    return '💎 Premium';
  }

  Widget _initialeWidget(String initiale) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Text(
          initiale,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD85A30),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final nom = user?.displayName ?? user?.email?.split('@')[0] ?? 'Utilisateur';
    final email = user?.email ?? '';
    final initiale = nom.isNotEmpty ? nom[0].toUpperCase() : '?';

    final cardColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD85A30), Color(0xFF8B2500)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickPhoto,
                    child: Stack(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _photoPath != null
                                ? Image.file(
                                    File(_photoPath!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _initialeWidget(initiale),
                                  )
                                : _initialeWidget(initiale),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Color(0xFFD85A30),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(nom,
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(email,
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.8))),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mes préférences',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: textColor)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _categories.map((cat) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD85A30).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: const Color(0xFFD85A30)
                                        .withOpacity(0.3)),
                              ),
                              child: Text(cat,
                                  style: const TextStyle(
                                      color: Color(0xFFD85A30),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text('Budget : ',
                                style: TextStyle(
                                    color: textColor.withOpacity(0.5))),
                            Text(_budgetLabel,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFD85A30))),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        _ActionTile(
                          icon: Icons.edit_outlined,
                          label: 'Modifier le profil',
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const EditProfilePage()),
                            );
                            setState(() {});
                          },
                        ),
                        Divider(height: 1, indent: 56,
                            color: textColor.withOpacity(0.1)),
                        _ActionTile(
                          icon: Icons.tune_outlined,
                          label: 'Modifier mes préférences',
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const EditPreferencesPage()),
                            );
                            _loadPrefs();
                          },
                        ),
                        Divider(height: 1, indent: 56,
                            color: textColor.withOpacity(0.1)),
                        _ActionTile(
                          icon: Icons.notifications_outlined,
                          label: 'Notifications',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const NotificationsPage()),
                            );
                          },
                        ),
                        Divider(height: 1, indent: 56,
                            color: textColor.withOpacity(0.1)),
                        _DarkModeTile(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  GestureDetector(
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: Color(0xFFD85A30)),
                          SizedBox(width: 8),
                          Text('Se déconnecter',
                              style: TextStyle(
                                  color: Color(0xFFD85A30),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoSourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PhotoSourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFD85A30).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFD85A30), size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFD85A30).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFFD85A30), size: 18),
      ),
      title: Text(label,
          style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: textColor)),
      trailing: Icon(Icons.arrow_forward_ios,
          size: 14, color: textColor.withOpacity(0.4)),
      onTap: onTap,
    );
  }
}

class _DarkModeTile extends StatefulWidget {
  @override
  State<_DarkModeTile> createState() => _DarkModeTileState();
}

class _DarkModeTileState extends State<_DarkModeTile> {
  bool _isDark = false;

  @override
  void initState() {
    super.initState();
    _loadDarkMode();
  }

  Future<void> _loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isDark = prefs.getBool('dark_mode') ?? false);
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFD85A30).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          _isDark ? Icons.dark_mode : Icons.light_mode,
          color: const Color(0xFFD85A30),
          size: 18,
        ),
      ),
      title: Text(
        _isDark ? 'Mode sombre' : 'Mode clair',
        style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: textColor),
      ),
      trailing: Switch(
        value: _isDark,
        activeColor: const Color(0xFFD85A30),
        onChanged: (val) async {
          await MyApp.of(context)?.toggleDarkMode();
          setState(() => _isDark = val);
        },
      ),
    );
  }
}