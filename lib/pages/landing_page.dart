import 'package:flutter/material.dart';
import 'package:gotime/lib/auth_gate.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'emoji': '🎯',
      'titre': 'Découvre quoi faire',
      'desc':
          'GoTime analyse tes préférences, ta position et la météo pour te proposer les meilleures activités autour de toi.',
      'color': const Color(0xFFD85A30),
    },
    {
      'emoji': '🧠',
      'titre': 'Une IA pour toi',
      'desc':
          'Notre moteur intelligent apprend ce que tu aimes et te recommande des activités avec un score de pertinence en temps réel.',
      'color': const Color(0xFF6C63FF),
    },
    {
      'emoji': '📍',
      'titre': 'Près de toi',
      'desc':
          'Trouve des terrains, cafés, restaurants et lieux de divertissement à quelques minutes de ta position.',
      'color': const Color(0xFF2ECC71),
    },
    {
      'emoji': '🎲',
      'titre': 'Tu t\'ennuies ?',
      'desc':
          'Appuie sur "Je m\'ennuie" et GoTime te suggère instantanément une activité parfaite pour le moment.',
      'color': const Color(0xFFFF9500),
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextSlide() {
    if (_currentPage < _slides.length - 1) {
      _controller.reset();
      setState(() => _currentPage++);
      _controller.forward();
    } else {
      _goToAuth();
    }
  }

  void _goToAuth() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthGate()),
    );
  }

  void _goVisiteur() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentPage];
    final color = slide['color'] as Color;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Skip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo
                    const Text(
                      'GoTime',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: _goToAuth,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Passer',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Emoji principal
                FadeTransition(
                  opacity: _fadeIn,
                  child: Text(
                    slide['emoji'],
                    style: const TextStyle(fontSize: 90),
                  ),
                ),

                const SizedBox(height: 30),

                // Titre
                FadeTransition(
                  opacity: _fadeIn,
                  child: Text(
                    slide['titre'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Description
                FadeTransition(
                  opacity: _fadeIn,
                  child: Text(
                    slide['desc'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),

                const Spacer(),

                // Indicateurs
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _slides.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _currentPage ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _currentPage
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Bouton suivant / commencer
                GestureDetector(
                  onTap: _nextSlide,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _currentPage < _slides.length - 1
                            ? 'Suivant →'
                            : 'Commencer 🚀',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Mode visiteur
                GestureDetector(
                  onTap: _goVisiteur,
                  child: Text(
                    'Continuer sans compte →',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}