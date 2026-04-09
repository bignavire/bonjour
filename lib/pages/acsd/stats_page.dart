import 'package:flutter/material.dart';
import 'package:gotime/pages/task_data.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F0EE);
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subTextColor = isDark ? Colors.white70 : Colors.grey;

    final today = DateTime.now();
    final cleanDate = DateTime.utc(today.year, today.month, today.day);
    final tasks = TaskData.tasks[cleanDate] ?? [];
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((t) => t["done"] == true).length;
    final progress = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Statistiques"),
        centerTitle: true,
        backgroundColor: const Color(0xFFD85A30),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD85A30), Color(0xFFFF8C5A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD85A30).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Progression du jour",
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text(
                    "$completedTasks / $totalTasks tâches",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.white30,
                      valueColor:
                          const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${(progress * 100).toInt()}% complété",
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statBox("Total", totalTasks, Colors.blue, cardColor, textColor, subTextColor),
                _statBox("Faites", completedTasks, Colors.green, cardColor, textColor, subTextColor),
                _statBox("Restantes", totalTasks - completedTasks, Colors.red, cardColor, textColor, subTextColor),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                progress > 0.7
                    ? "🔥 Excellent travail aujourd'hui !"
                    : progress > 0.4
                        ? "💪 Continue comme ça !"
                        : "🚀 Tu peux encore faire mieux !",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _statBox(String title, int value, Color color, Color cardColor,
    Color textColor, Color subTextColor) {
  return Container(
    width: 100,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.15),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      children: [
        Text(
          "$value",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(title,
            style: TextStyle(fontSize: 12, color: subTextColor)),
      ],
    ),
  );
}