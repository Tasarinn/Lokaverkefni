import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:intl/intl.dart';

class PastDayScreen extends StatefulWidget {
  const PastDayScreen({super.key});

  @override
  State<PastDayScreen> createState() => _PastDayScreenState();
}

class _PastDayScreenState extends State<PastDayScreen> {
  DateTime? selectedDate;
  int consumedCalories = 0;
  int consumedProtein = 0;
  int consumedCarbs = 0;
  int consumedFat = 0;

  int calorieGoal = 0;
  int proteinGoal = 0;
  int carbGoal = 0;
  int fatGoal = 0;

  double currentWeight = 0.0;
  double targetWeight = 0.0;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  void _loadGoals() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('goals').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        calorieGoal = data['calories'] ?? 0;
        proteinGoal = data['protein'] ?? 0;
        carbGoal = data['carbs'] ?? 0;
        fatGoal = data['fat'] ?? 0;
        currentWeight = (data['currentWeight'] ?? 0).toDouble();
        targetWeight = (data['targetWeight'] ?? 0).toDouble();
      });
    }
  }

  void _loadDayData(DateTime date) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final dateKey = DateFormat('yyyy-MM-dd').format(date);

    final doc = await FirebaseFirestore.instance
        .collection('foodLogs')
        .doc(user.uid)
        .collection('days')
        .doc(dateKey)
        .get();

    if (doc.exists) {
      final data = doc.data();
      final entries = List<Map<String, dynamic>>.from(data?['entries'] ?? []);

      int cal = 0, pro = 0, carbs = 0, fat = 0;

      for (var entry in entries) {
        cal += ((entry['calories'] ?? 0) as num).round();
        pro += ((entry['protein'] ?? 0) as num).round();
        carbs += ((entry['carbs'] ?? 0) as num).round();
        fat += ((entry['fat'] ?? 0) as num).round();
      }

      setState(() {
        consumedCalories = cal;
        consumedProtein = pro;
        consumedCarbs = carbs;
        consumedFat = fat;
      });
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
      _loadDayData(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fyrri Dagur"), backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickDate,
              child: const Text("Veldu dagsetningu"),
            ),
            const SizedBox(height: 20),
            if (selectedDate != null)
              Column(
                children: [
                  CircularPercentIndicator(
                    radius: 100,
                    lineWidth: 12,
                    percent: calorieGoal > 0
                        ? (consumedCalories / calorieGoal).clamp(0.0, 1.0)
                        : 0.0,
                    center: Text("$consumedCalories / $calorieGoal kcal"),
                    progressColor: Colors.blue,
                    backgroundColor: Colors.grey[300]!,
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          const Text('Prótein'),
                          Text('$consumedProtein g / $proteinGoal g'),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Kolvetni'),
                          Text('$consumedCarbs g / $carbGoal g'),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Fita'),
                          Text('$consumedFat g / $fatGoal g'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Núverandi þyngd: ${currentWeight.toStringAsFixed(1)} kg'),
                  Text('Markmið þyngd: ${targetWeight.toStringAsFixed(1)} kg'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
