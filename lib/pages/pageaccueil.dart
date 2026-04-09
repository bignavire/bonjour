import 'package:flutter/material.dart';
import 'package:gotime/pages/acsd/calendar_page.dart';
import 'package:gotime/pages/acsd/stats_page.dart';
import 'package:gotime/pages/profile_page.dart';
import 'package:gotime/pages/acsd/add_task_page.dart';
import 'package:gotime/pages/task_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gotime/pages/notification_service.dart';
import 'package:gotime/lib/models/activity.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gotime/lib/models/user_preferences.dart';
import 'package:gotime/lib/services/recommendation_engine.dart';
import 'package:gotime/lib/services/weather_service.dart';
import 'package:gotime/lib/services/places_service.dart';
import 'dart:async';

class Pageaccueil extends StatefulWidget {
  const Pageaccueil({super.key});

  @override
  State<Pageaccueil> createState() => _PageaccueilState();
}

class _PageaccueilState extends State<Pageaccueil> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    const _HomeContent(),
    const CalendarPage(),
    const StatsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/marron.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: pages[selectedIndex],
        bottomNavigationBar: _BottomNav(
          selectedIndex: selectedIndex,
          onItemTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return SafeArea(
      child: Column(
        children: [
          _Header(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: bg),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: const [
                    _TachesCard(),
                    SizedBox(height: 14),
                    _EnvieButton(),
                    SizedBox(height: 14),
                    _SuggestionsSection(),
                    SizedBox(height: 14),
                    _ProcheDeToiCard(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatefulWidget {
  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  String _meteo = '';
  String _heure = '';
  String _salutation = '';

  @override
  void initState() {
    super.initState();
    _updateHeure();
    _loadMeteo();
    Timer.periodic(const Duration(seconds: 30), (_) {
      _updateHeure();
    });
  }

  void _updateHeure() {
    final now = DateTime.now();
    final h = now.hour;
    setState(() {
      _heure =
          '${h.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      if (h >= 5 && h < 12) {
        _salutation = 'Bonjour';
      } else if (h >= 12 && h < 18) {
        _salutation = 'Bon après-midi';
      } else {
        _salutation = 'Bonsoir';
      }
    });
  }

  Future<void> _loadMeteo() async {
    try {
      final weather = await WeatherService.getWeather(5.3600, -4.0083);
      setState(() {
        if (weather == 'sunny') {
          _meteo = '☀️ Ensoleillé';
        } else if (weather == 'rainy') {
          _meteo = '🌧️ Pluvieux';
        } else {
          _meteo = '⛅ Nuageux';
        }
      });
    } catch (_) {
      setState(() => _meteo = '☀️ Abidjan');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final nom = user?.displayName ?? "Utilisateur";
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 36, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_meteo,
                      style: const TextStyle(fontSize: 13, color: Colors.white70)),
                  Text(_heure,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              GestureDetector(
                onTap: () async => await FirebaseAuth.instance.signOut(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.logout, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('$_salutation, $nom 👋',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 2),
          const Text('Que fais-tu aujourd\'hui ?',
              style: TextStyle(fontSize: 13, color: Colors.white70)),
        ],
      ),
    );
  }
}

class _TachesCard extends StatefulWidget {
  const _TachesCard();

  @override
  State<_TachesCard> createState() => _TachesCardState();
}

class _TachesCardState extends State<_TachesCard> {
  List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('tasks');
    if (data != null) {
      Map<String, dynamic> decoded = jsonDecode(data);
      TaskData.tasks = decoded.map((key, value) {
        return MapEntry(DateTime.parse(key),
            List<Map<String, dynamic>>.from(value));
      });
    }
    final today = DateTime.now();
    final cleanDate = DateTime.utc(today.year, today.month, today.day);
    setState(() {
      _tasks = TaskData.tasks[cleanDate] ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: cardColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tâches du jour 📋',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15, color: textColor)),
              Text(
                '${_tasks.where((t) => t["done"] == true).length}/${_tasks.length}',
                style: const TextStyle(
                    color: Color(0xFFD85A30), fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          if (_tasks.isEmpty) ...[
            const SizedBox(height: 10),
            Text('Aucune tâche aujourd\'hui 🎉',
                style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          ] else ...[
            const SizedBox(height: 10),
            ..._tasks.take(3).map((task) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 20, height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: task["done"]
                              ? const Color(0xFFD85A30)
                              : Colors.transparent,
                          border: Border.all(
                              color: task["done"]
                                  ? const Color(0xFFD85A30)
                                  : Colors.grey,
                              width: 2),
                        ),
                        child: task["done"]
                            ? const Icon(Icons.check, color: Colors.white, size: 12)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(task["title"],
                            style: TextStyle(
                              color: task["done"] ? Colors.grey : textColor,
                              decoration: task["done"]
                                  ? TextDecoration.lineThrough
                                  : null,
                              fontSize: 13,
                            )),
                      ),
                    ],
                  ),
                )),
            if (_tasks.length > 3)
              Text('+ ${_tasks.length - 3} autres tâches',
                  style: const TextStyle(
                      color: Color(0xFFD85A30),
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
          ],
        ],
      ),
    );
  }
}

class _EnvieButton extends StatefulWidget {
  const _EnvieButton();

  @override
  State<_EnvieButton> createState() => _EnvieButtonState();
}

class _EnvieButtonState extends State<_EnvieButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  String? _suggestion;

  final List<Map<String, String>> _activites = [
    {'emoji': '🏀', 'nom': 'Terrain de basket', 'lieu': 'Yopougon'},
    {'emoji': '☕', 'nom': 'Café sympa', 'lieu': 'Plateau'},
    {'emoji': '🎬', 'nom': 'Ciné Majestic', 'lieu': 'Marcory'},
    {'emoji': '🏃', 'nom': 'Jogging Banco', 'lieu': 'Banco'},
    {'emoji': '🎳', 'nom': 'Bowling Palace', 'lieu': 'Cocody'},
    {'emoji': '🎮', 'nom': 'Gaming Zone', 'lieu': 'Yopougon'},
    {'emoji': '🍔', 'nom': 'Street Food', 'lieu': 'Adjamé'},
    {'emoji': '🎵', 'nom': 'Concert Live', 'lieu': 'Zone 4'},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() async {
    await _controller.forward();
    await _controller.reverse();
    final random = (_activites..shuffle()).first;
    setState(() {
      _suggestion = '${random['emoji']} ${random['nom']} — ${random['lieu']}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _onTap,
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD85A30), Color(0xFFFF8C5A)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD85A30).withOpacity(0.35),
                    blurRadius: 12, offset: const Offset(0, 5)),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🎲', style: TextStyle(fontSize: 22)),
                  SizedBox(width: 10),
                  Text('Je m\'ennuie',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5)),
                ],
              ),
            ),
          ),
        ),
        if (_suggestion != null) ...[
          const SizedBox(height: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFD85A30).withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFD85A30).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, color: Color(0xFFD85A30), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(_suggestion!,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFFD85A30))),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final Activity activity;
  final int rank;

  const _SuggestionCard({required this.activity, required this.rank});

  Color get _rankColor {
    if (rank == 1) return const Color(0xFFD85A30);
    if (rank == 2) return const Color(0xFF6C63FF);
    return const Color(0xFF2ECC71);
  }

  String get _budgetLabel {
    if (activity.budget == 'gratuit') return '🆓 Gratuit';
    if (activity.budget == 'moyen') return '💰 Moyen';
    return '💎 Premium';
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subTextColor =
        Theme.of(context).colorScheme.onSurface.withOpacity(0.5);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: _rankColor.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
                left: 0, top: 0, bottom: 0,
                child: Container(width: 5, color: _rankColor)),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
              child: Row(
                children: [
                  Column(
                    children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          color: _rankColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(activity.emoji,
                              style: const TextStyle(fontSize: 26)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('#$rank',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _rankColor)),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(activity.name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: textColor)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.category_outlined,
                                size: 12, color: subTextColor),
                            const SizedBox(width: 4),
                            Text(activity.category,
                                style: TextStyle(
                                    color: subTextColor, fontSize: 12)),
                            const SizedBox(width: 10),
                            Text(_budgetLabel,
                                style: TextStyle(
                                    color: subTextColor, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: activity.score / 100,
                                  backgroundColor:
                                      subTextColor.withOpacity(0.2),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      _rankColor),
                                  minHeight: 6,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('${activity.score.toInt()}%',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: _rankColor)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios,
                      size: 14, color: subTextColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionsSection extends StatefulWidget {
  const _SuggestionsSection();

  @override
  State<_SuggestionsSection> createState() => _SuggestionsSectionState();
}

class _SuggestionsSectionState extends State<_SuggestionsSection> {
  List<Activity> _recs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      Position position;
      try {
        final permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          throw Exception('Permission refusée');
        }
        position = await Geolocator.getCurrentPosition();
      } catch (_) {
        position = Position(
          latitude: 5.3489, longitude: -4.0712,
          timestamp: DateTime.now(),
          accuracy: 0, altitude: 0, heading: 0,
          speed: 0, speedAccuracy: 0,
          altitudeAccuracy: 0, headingAccuracy: 0,
        );
      }

      final places = await PlacesService.getPlacesAround(
        lat: position.latitude,
        lng: position.longitude,
      );

      final activities = places.asMap().entries.map((e) {
        final p = e.value;
        return Activity(
          id: 'p${e.key}',
          name: p['name'],
          category: p['category'],
          budget: p['budget'],
          isOutdoor: p['isOutdoor'],
          lat: p['lat'],
          lng: p['lng'],
          emoji: p['emoji'],
        );
      }).toList();

      final prefs = await UserPreferences.load();
      final weather = await WeatherService.getWeather(
          position.latitude, position.longitude);
      final sharedPrefs = await SharedPreferences.getInstance();
      final history = sharedPrefs.getStringList('history') ?? [];

      final recs = activities.isEmpty
          ? <Activity>[]
          : await RecommendationEngine.recommend(
              activities: activities,
              prefs: prefs,
              weather: weather,
              position: position,
              history: history,
            );

      setState(() {
        _recs = recs;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final cardColor = Theme.of(context).colorScheme.surface;

    if (_loading) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
            color: cardColor, borderRadius: BorderRadius.circular(20)),
        child: const Center(
            child: CircularProgressIndicator(color: Color(0xFFD85A30))),
      );
    }

    if (_recs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: cardColor, borderRadius: BorderRadius.circular(20)),
        child: Center(
          child: Text('Aucune activité trouvée près de toi 📍',
              style: TextStyle(color: textColor)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Pour toi maintenant 🎯',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor)),
            const Text('Voir tout',
                style: TextStyle(
                    color: Color(0xFFD85A30),
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 12),
        ..._recs.asMap().entries.map(
              (e) => _SuggestionCard(activity: e.value, rank: e.key + 1),
            ),
      ],
    );
  }
}

class _ProcheDeToiCard extends StatefulWidget {
  const _ProcheDeToiCard();

  @override
  State<_ProcheDeToiCard> createState() => _ProcheDeToiCardState();
}

class _ProcheDeToiCardState extends State<_ProcheDeToiCard> {
  List<Map<String, dynamic>> _lieux = [];
  bool _loading = true;

  final List<Color> _colors = const [
    Color(0xFFD85A30), Color(0xFF6C63FF),
    Color(0xFFFF9500), Color(0xFF2ECC71),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      Position position;
      try {
        position = await Geolocator.getCurrentPosition();
      } catch (_) {
        position = Position(
          latitude: 5.3489, longitude: -4.0712,
          timestamp: DateTime.now(),
          accuracy: 0, altitude: 0, heading: 0,
          speed: 0, speedAccuracy: 0,
          altitudeAccuracy: 0, headingAccuracy: 0,
        );
      }

      final places = await PlacesService.getPlacesAround(
        lat: position.latitude,
        lng: position.longitude,
      );

      setState(() {
        _lieux = places;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final cardColor = Theme.of(context).colorScheme.surface;

    if (_loading) {
      return Container(
        height: 130,
        decoration: BoxDecoration(
            color: cardColor, borderRadius: BorderRadius.circular(16)),
        child: const Center(
            child: CircularProgressIndicator(color: Color(0xFFD85A30))),
      );
    }

    if (_lieux.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: cardColor, borderRadius: BorderRadius.circular(16)),
        child: Center(
          child: Text('Aucun lieu trouvé nearby 📍',
              style: TextStyle(color: textColor)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Près de toi 📍',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor)),
            const Text('Voir tout',
                style: TextStyle(
                    color: Color(0xFFD85A30),
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _lieux.length,
            itemBuilder: (context, index) {
              final lieu = _lieux[index];
              final color = _colors[index % _colors.length];
              return Container(
                width: 130,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                        color: color.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(lieu['emoji'],
                              style: const TextStyle(fontSize: 20)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(lieu['name'],
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: textColor),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 11, color: color),
                          const SizedBox(width: 2),
                          Text(lieu['distanceLabel'],
                              style: TextStyle(
                                  fontSize: 11,
                                  color: color,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTap;

  const _BottomNav({required this.selectedIndex, required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    final navBg = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Container(
      color: navBg,
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _NavItem(icon: Icons.grid_view_rounded, label: 'Accueil', active: selectedIndex == 0, onTap: () => onItemTap(0)),
          _NavItem(icon: Icons.calendar_today_outlined, label: 'Calendrier', active: selectedIndex == 1, onTap: () => onItemTap(1)),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.translate(
                offset: const Offset(0, -14),
                child: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD85A30),
                    shape: BoxShape.circle,
                    border: Border.all(color: navBg, width: 3),
                  ),
                  child: GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(context,
                          MaterialPageRoute(
                              builder: (context) => const AddTaskPage()));
                      if (result != null) {
                        String task = result["task"];
                        DateTime date = result["date"];
                        final cleanDate =
                            DateTime.utc(date.year, date.month, date.day);
                        if (TaskData.tasks[cleanDate] != null) {
                          TaskData.tasks[cleanDate]!
                              .add({"title": task, "done": false});
                        } else {
                          TaskData.tasks[cleanDate] = [
                            {"title": task, "done": false}
                          ];
                        }
                        saveTasks();
                        NotificationService().scheduleNotification(
                            id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                            title: "Tâche",
                            body: task,
                            dateTime: date);
                      }
                    },
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ),
              Text("Ajouter",
                  style: TextStyle(color: textColor, fontSize: 10)),
            ],
          ),
          _NavItem(icon: Icons.show_chart_outlined, label: 'Stats', active: selectedIndex == 2, onTap: () => onItemTap(2)),
          _NavItem(icon: Icons.person_outline, label: 'Profil', active: selectedIndex == 3, onTap: () => onItemTap(3)),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _NavItem(
      {required this.icon, required this.label, this.active = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active
        ? const Color(0xFFD85A30)
        : Theme.of(context).colorScheme.onSurface.withOpacity(0.5);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          active
              ? Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                      color: const Color(0xFFD85A30),
                      borderRadius: BorderRadius.circular(6)),
                  child: Icon(icon, size: 13, color: Colors.white))
              : Icon(icon, size: 22, color: color),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontSize: 10, color: color)),
        ],
      ),
    );
  }
}

Future<void> saveTasks() async {
  final prefs = await SharedPreferences.getInstance();
  Map<String, List<Map<String, dynamic>>> encodedTasks = {};
  TaskData.tasks.forEach((key, value) {
    encodedTasks[key.toIso8601String()] = value;
  });
  prefs.setString('tasks', jsonEncode(encodedTasks));
}