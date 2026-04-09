import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:gotime/pages/task_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime today = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, List<Map<String, dynamic>>> encodedTasks = {};
    TaskData.tasks.forEach((key, value) {
      encodedTasks[key.toIso8601String()] = value;
    });
    prefs.setString('tasks', jsonEncode(encodedTasks));
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('tasks');
    if (data != null) {
      Map<String, dynamic> decoded = jsonDecode(data);
      setState(() {
        TaskData.tasks = decoded.map((key, value) {
          return MapEntry(
            DateTime.parse(key),
            List<Map<String, dynamic>>.from(value),
          );
        });
      });
    }
  }

  List<Map<String, dynamic>> getTasksForDay(DateTime day) {
    return TaskData.tasks.entries
        .firstWhere(
          (entry) =>
              entry.key.year == day.year &&
              entry.key.month == day.month &&
              entry.key.day == day.day,
          orElse: () => MapEntry(day, []),
        )
        .value;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      today = selectedDay;
    });
  }

  String get _formattedDate {
    const mois = [
      '', 'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    const jours = [
      '', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'
    ];
    return '${jours[today.weekday]} ${today.day} ${mois[today.month]}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F0EE);
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final tasks = getTasksForDay(today);
    final completed = tasks.where((t) => t["done"] == true).length;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFD85A30), Color(0xFF8B2500)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Calendrier',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TableCalendar(
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                      leftChevronIcon:
                          Icon(Icons.chevron_left, color: Colors.white),
                      rightChevronIcon:
                          Icon(Icons.chevron_right, color: Colors.white),
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(color: Colors.white70),
                      weekendStyle: TextStyle(color: Colors.white54),
                    ),
                    calendarStyle: CalendarStyle(
                      defaultTextStyle: const TextStyle(color: Colors.white),
                      weekendTextStyle:
                          const TextStyle(color: Colors.white70),
                      outsideTextStyle:
                          const TextStyle(color: Colors.white30),
                      todayDecoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: const TextStyle(
                        color: Color(0xFFD85A30),
                        fontWeight: FontWeight.bold,
                      ),
                      markerDecoration: const BoxDecoration(
                        color: Color(0xFFFFBD43),
                        shape: BoxShape.circle,
                      ),
                    ),
                    selectedDayPredicate: (day) => isSameDay(day, today),
                    focusedDay: today,
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    onDaySelected: _onDaySelected,
                    eventLoader: (day) {
                      final t = getTasksForDay(day);
                      return t.any((task) => task["done"] == false) ? t : [];
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Date + compteur
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formattedDate,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                if (tasks.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD85A30).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$completed/${tasks.length} faites',
                      style: const TextStyle(
                        color: Color(0xFFD85A30),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Liste tâches
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('📭', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 10),
                        Text(
                          'Aucune tâche ce jour',
                          style: TextStyle(color: textColor, fontSize: 15),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return GestureDetector(
                        onLongPress: () {
                          final controller =
                              TextEditingController(text: task["title"]);
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Modifier la tâche"),
                              content: TextField(controller: controller),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Annuler"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      task["title"] = controller.text;
                                    });
                                    saveTasks();
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Modifier"),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: GestureDetector(
                              onTap: () {
                                setState(() {
                                  task["done"] = !(task["done"] as bool);
                                });
                                saveTasks();
                              },
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: task["done"]
                                      ? const Color(0xFFD85A30)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: task["done"]
                                        ? const Color(0xFFD85A30)
                                        : Colors.grey,
                                    width: 2,
                                  ),
                                ),
                                child: task["done"]
                                    ? const Icon(Icons.check,
                                        color: Colors.white, size: 14)
                                    : null,
                              ),
                            ),
                            title: Text(
                              task["title"],
                              style: TextStyle(
                                color: textColor,
                                decoration: task["done"]
                                    ? TextDecoration.lineThrough
                                    : null,
                                decorationColor: Colors.grey,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.grey, size: 20),
                              onPressed: () {
                                setState(() {
                                  final date = DateTime.utc(
                                      today.year, today.month, today.day);
                                  TaskData.tasks[date]!.remove(task);
                                  if (TaskData.tasks[date]!.isEmpty) {
                                    TaskData.tasks.remove(date);
                                  }
                                });
                                saveTasks();
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}