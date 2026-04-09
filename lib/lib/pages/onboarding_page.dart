import 'package:flutter/material.dart';
import 'package:gotime/lib/models/user_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final List<String> _categories = [];
  String _budget = 'gratuit';
  int _step = 0;

  final List<Map<String, String>> _allCategories = [
    {'id': 'sport', 'emoji': '💪', 'label': 'Sport'},
    {'id': 'chill', 'emoji': '😴', 'label': 'Chill'},
    {'id': 'culture', 'emoji': '🎭', 'label': 'Culture'},
    {'id': 'fun', 'emoji': '🎉', 'label': 'Fun'},
    {'id': 'food', 'emoji': '🍔', 'label': 'Food'},
    {'id': 'musique', 'emoji': '🎵', 'label': 'Musique'},
  ];

  final List<Map<String, String>> _budgets = [
    {'id': 'gratuit', 'emoji': '🆓', 'label': 'Gratuit'},
    {'id': 'moyen', 'emoji': '💰', 'label': 'Moyen'},
    {'id': 'premium', 'emoji': '💎', 'label': 'Premium'},
  ];

 Future<void> _finish() async {
  final prefs = UserPreferences(
    categories: _categories.isEmpty ? ['sport'] : _categories,
    budget: _budget,
  );
  await prefs.save();

  final sharedPrefs = await SharedPreferences.getInstance();
  await sharedPrefs.setBool('onboarding_done', true);

  if (!mounted) return;
  Navigator.pushReplacementNamed(context, '/home');
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD85A30), Color(0xFF8B2500)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress
                Row(
                  children: List.generate(2, (i) => Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: i <= _step
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )),
                ),
                const SizedBox(height: 40),

                if (_step == 0) ...[
                  const Text('Tu aimes quoi ?',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('Choisis tes centres d\'intérêt',
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.8))),
                  const SizedBox(height: 32),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _allCategories.map((cat) {
                      final selected = _categories.contains(cat['id']);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selected) {
                              _categories.remove(cat['id']);
                            } else {
                              _categories.add(cat['id']!);
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.white
                                : Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(cat['emoji']!,
                                  style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Text(
                                cat['label']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? const Color(0xFFD85A30)
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                if (_step == 1) ...[
                  const Text('Ton budget ?',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('Pour les activités recommandées',
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.8))),
                  const SizedBox(height: 32),
                  ..._budgets.map((b) {
                    final selected = _budget == b['id'];
                    return GestureDetector(
                      onTap: () => setState(() => _budget = b['id']!),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.white
                              : Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: selected
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(b['emoji']!,
                                style: const TextStyle(fontSize: 26)),
                            const SizedBox(width: 16),
                            Text(
                              b['label']!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: selected
                                    ? const Color(0xFFD85A30)
                                    : Colors.white,
                              ),
                            ),
                            const Spacer(),
                            if (selected)
                              const Icon(Icons.check_circle,
                                  color: Color(0xFFD85A30)),
                          ],
                        ),
                      ),
                    );
                  }),
                ],

                const Spacer(),

                // Bouton suivant / terminer
                GestureDetector(
                  onTap: () {
                    if (_step == 0) {
                      setState(() => _step = 1);
                    } else {
                      _finish();
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Text(
                        _step == 0 ? 'Suivant →' : 'C\'est parti 🚀',
                        style: const TextStyle(
                          color: Color(0xFFD85A30),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}