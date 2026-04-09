import 'package:flutter/material.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController controller = TextEditingController();
  TimeOfDay? selectedTime;
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F0EE);
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Ajouter une tâche"),
        centerTitle: true,
        backgroundColor: const Color(0xFFD85A30),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: controller,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: "Entrer une tâche",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: InputBorder.none,
                  icon: const Icon(Icons.task_alt,
                      color: Color(0xFFD85A30)),
                ),
              ),
            ),

            const SizedBox(height: 14),

            GestureDetector(
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (pickedDate != null) {
                  setState(() => selectedDate = pickedDate);
                }
              },
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
                      "Date : ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                      style: TextStyle(
                          color: textColor, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            GestureDetector(
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  setState(() => selectedTime = picked);
                }
              },
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
                      selectedTime == null
                          ? "Choisir une heure"
                          : "Heure : ${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}",
                      style: TextStyle(
                          color: textColor, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            GestureDetector(
              onTap: () {
                if (controller.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Entre une tâche")),
                  );
                  return;
                }
                if (selectedTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Choisis une heure")),
                  );
                  return;
                }

                final fullDate = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime!.hour,
                  selectedTime!.minute,
                );

                Navigator.pop(context, {
                  "task": controller.text,
                  "date": fullDate,
                });
              },
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
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Ajouter la tâche ✅',
                    style: TextStyle(
                      color: Colors.white,
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
    );
  }
}