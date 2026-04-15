import 'package:flutter/material.dart';
import 'package:gotime/lib/models/activity.dart';
import 'package:gotime/pages/task_data.dart';
import 'package:gotime/pages/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ActivityDetailPage extends StatefulWidget {
  final Activity activity;

  const ActivityDetailPage({super.key, required this.activity});

  @override
  State<ActivityDetailPage> createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _rappelActif = true;

  String get _budgetLabel {
    if (widget.activity.budget == 'gratuit') return '🆓 Gratuit';
    if (widget.activity.budget == 'moyen') return '💰 Moyen';
    return '💎 Premium';
  }

  Future<void> _choisirDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFD85A30),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _choisirHeure() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFD85A30),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _ajouterTache() async {
    final fullDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final cleanDate = DateTime.utc(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    final tache = '${widget.activity.emoji} ${widget.activity.name}';

    // 📅 Ajouter dans TaskData
    if (TaskData.tasks[cleanDate] != null) {
      TaskData.tasks[cleanDate]!.add({'title': tache, 'done': false});
    } else {
      TaskData.tasks[cleanDate] = [{'title': tache, 'done': false}];
    }

    // 💾 Sauvegarder
    final prefs = await SharedPreferences.getInstance();
    Map<String, List<Map<String, dynamic>>> encodedTasks = {};
    TaskData.tasks.forEach((key, value) {
      encodedTasks[key.toIso8601String()] = value;
    });
    await prefs.setString('tasks', jsonEncode(encodedTasks));

    // 🔔 Notification si activée
    if (_rappelActif) {
      await NotificationService().scheduleNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: '⏰ GoTime — ${widget.activity.name}',
        body: 'C\'est l\'heure pour : $tache',
        dateTime: fullDate,
      );
    }

    if (!mounted) return;

    // ✅ Confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ "${widget.activity.name}" ajouté au calendrier !'),
        backgroundColor: const Color(0xFFD85A30),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).colorScheme.surface;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // 🎨 HEADER
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
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
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
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  widget.activity.emoji,
                  style: const TextStyle(fontSize: 60),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.activity.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.activity.category,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _budgetLabel,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 📅 PLANIFICATION
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Planifier cette activité',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 📅 Date
                  GestureDetector(
                    onTap: _choisirDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              color: Color(0xFFD85A30), size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'Date : ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          Icon(Icons.edit_outlined,
                              size: 16,
                              color: textColor.withOpacity(0.4)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ⏰ Heure
                  GestureDetector(
                    onTap: _choisirHeure,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time,
                              color: Color(0xFFD85A30), size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'Heure : ${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          Icon(Icons.edit_outlined,
                              size: 16,
                              color: textColor.withOpacity(0.4)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 🔔 Rappel
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SwitchListTile(
                      secondary: const Icon(Icons.notifications_outlined,
                          color: Color(0xFFD85A30)),
                      title: Text('Rappel notification',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: textColor)),
                      subtitle: Text(
                        'Recevoir une notification à l\'heure choisie',
                        style: TextStyle(
                            fontSize: 12,
                            color: textColor.withOpacity(0.5)),
                      ),
                      value: _rappelActif,
                      activeColor: const Color(0xFFD85A30),
                      onChanged: (val) =>
                          setState(() => _rappelActif = val),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ➕ BOUTON AJOUTER
                  GestureDetector(
                    onTap: _ajouterTache,
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
                            color:
                                const Color(0xFFD85A30).withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          '➕ Ajouter à mes tâches',
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
          ),
        ],
      ),
    );
  }
}