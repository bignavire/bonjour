import 'package:flutter/material.dart';
import 'package:gotime/lib/models/user_preferences.dart';

class EditPreferencesPage extends StatefulWidget {
  const EditPreferencesPage({super.key});

  @override
  State<EditPreferencesPage> createState() => _EditPreferencesPageState();
}

class _EditPreferencesPageState extends State<EditPreferencesPage> {
  List<String> _categories = [];
  String _budget = 'gratuit';
  int _step = 0;
  bool _loading = true;

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

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  // 📥 Charger les préférences existantes
  Future<void> _loadExisting() async {
    final prefs = await UserPreferences.load();
    setState(() {
      _categories = List.from(prefs.categories);
      _budget = prefs.budget;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final prefs = UserPreferences(
      categories: _categories.isEmpty ? ['sport'] : _categories,
      budget: _budget,
    );
    await prefs.save();

    if (!mounted) return;
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Préférences sauvegardées !'),
        backgroundColor: Color(0xFFD85A30),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFD85A30)),
        ),
      );
    }

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
                // 🔙 Bouton retour + progress
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_step == 0) {
                          Navigator.pop(context);
                        } else {
                          setState(() => _step = 0);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ...List.generate(
                      2,
                      (i) => Expanded(
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
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // STEP 0 — Catégories
                if (_step == 0) ...[
                  const Text('Tu aimes quoi ?',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('Modifie tes centres d\'intérêt',
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

                // STEP 1 — Budget
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

                // Bouton suivant / sauvegarder
                GestureDetector(
                  onTap: () {
                    if (_step == 0) {
                      setState(() => _step = 1);
                    } else {
                      _save();
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
                        _step == 0 ? 'Suivant →' : '💾 Sauvegarder',
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