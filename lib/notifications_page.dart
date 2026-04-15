import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';



class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _notifActives = true;
  bool _notifTaches = true;
  bool _notifQuotidien = false;
  TimeOfDay _heureRappel = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifActives = prefs.getBool('notif_actives') ?? true;
      _notifTaches = prefs.getBool('notif_taches') ?? true;
      _notifQuotidien = prefs.getBool('notif_quotidien') ?? false;
      final hour = prefs.getInt('notif_heure') ?? 9;
      final minute = prefs.getInt('notif_minute') ?? 0;
      _heureRappel = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_actives', _notifActives);
    await prefs.setBool('notif_taches', _notifTaches);
    await prefs.setBool('notif_quotidien', _notifQuotidien);
    await prefs.setInt('notif_heure', _heureRappel.hour);
    await prefs.setInt('notif_minute', _heureRappel.minute);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Paramètres sauvegardés !'),
          backgroundColor: Color(0xFFD85A30),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _choisirHeure() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _heureRappel,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD85A30),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _heureRappel = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFFD85A30),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔔 SECTION PRINCIPALE
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD85A30).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.notifications,
                          color: Color(0xFFD85A30), size: 18),
                    ),
                    title: Text('Notifications actives',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: textColor)),
                    subtitle: Text('Activer toutes les notifications',
                        style: TextStyle(
                            fontSize: 12,
                            color: textColor.withOpacity(0.5))),
                    value: _notifActives,
                    activeColor: const Color(0xFFD85A30),
                    onChanged: (val) {
                      setState(() => _notifActives = val);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ⚙️ SECTION DÉTAILS
            AnimatedOpacity(
              opacity: _notifActives ? 1.0 : 0.4,
              duration: const Duration(milliseconds: 300),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    // Notifs tâches
                    SwitchListTile(
                      secondary: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD85A30).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.task_alt,
                            color: Color(0xFFD85A30), size: 18),
                      ),
                      title: Text('Rappels de tâches',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: textColor)),
                      subtitle: Text('Notifié avant chaque tâche',
                          style: TextStyle(
                              fontSize: 12,
                              color: textColor.withOpacity(0.5))),
                      value: _notifTaches && _notifActives,
                      activeColor: const Color(0xFFD85A30),
                      onChanged: _notifActives
                          ? (val) => setState(() => _notifTaches = val)
                          : null,
                    ),

                    Divider(height: 1, indent: 56,
                        color: textColor.withOpacity(0.1)),

                    // Rappel quotidien
                    SwitchListTile(
                      secondary: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD85A30).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.wb_sunny_outlined,
                            color: Color(0xFFD85A30), size: 18),
                      ),
                      title: Text('Rappel quotidien',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: textColor)),
                      subtitle: Text('Rappel chaque jour pour planifier',
                          style: TextStyle(
                              fontSize: 12,
                              color: textColor.withOpacity(0.5))),
                      value: _notifQuotidien && _notifActives,
                      activeColor: const Color(0xFFD85A30),
                      onChanged: _notifActives
                          ? (val) => setState(() => _notifQuotidien = val)
                          : null,
                    ),

                    // Heure du rappel
                    if (_notifQuotidien && _notifActives) ...[
                      Divider(height: 1, indent: 56,
                          color: textColor.withOpacity(0.1)),
                      ListTile(
                        leading: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD85A30).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.access_time,
                              color: Color(0xFFD85A30), size: 18),
                        ),
                        title: Text('Heure du rappel',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: textColor)),
                        trailing: GestureDetector(
                          onTap: _choisirHeure,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD85A30).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${_heureRappel.hour.toString().padLeft(2, '0')}:${_heureRappel.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                color: Color(0xFFD85A30),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 💾 BOUTON SAUVEGARDER
            GestureDetector(
              onTap: _saveSettings,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD85A30), Color(0xFF8B2500)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Text(
                    '💾 Sauvegarder',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}