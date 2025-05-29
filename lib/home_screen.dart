import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'dart:math';
import 'package:calorie_counter/add_food_screen.dart';
import 'package:calorie_counter/goal_screen.dart';
import 'package:calorie_counter/past_day_screen.dart';
import 'package:calorie_counter/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showQuote = false;
  double quoteOpacity = 0.0;
  String currentQuote = "";

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

  bool loadingGoals = true;

  final List<String> quotes = [
    "Everybody wants to be a bodybuilder, but don’t nobody wanna lift no heavy-ass weight. – Ronnie Coleman",
    "Yeah buddy! Light weight baby! – Ronnie Coleman",
    "The worst thing I can be is the same as everybody else. I hate that. – Arnold Schwarzenegger",
    "Blood, sweat, and respect. The first two you give, the last one you earn. – The Rock",
    "There’s no secret formula. I lift heavy, work hard, and aim to be the best. – Ronnie Coleman",
    "Pain is temporary, pride is forever.",
    "You’ll pass out before you die. So keep going.",
    "If you think lifting is dangerous, try being weak. Being weak is dangerous.",
    "Discipline is doing what you hate to do, but doing it like you love it. – Mike Tyson",
    "You can have results or excuses. Not both.",
    "Train insane or remain the same.",
    "Sweat is just fat crying.",
    "Comfort is the enemy of progress.",
    "You don’t need motivation. You need discipline."
  ];

  @override
  void initState() {
    super.initState();
    NotificationService().initialize().then((_) {
      NotificationService().scheduleDailyNotification();
    });
    _loadGoals();
    _loadTodaysTotals();
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
        loadingGoals = false;
      });
    } else {
      setState(() => loadingGoals = false);
    }
  }

  void _loadTodaysTotals() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final dateKey = now.toIso8601String().substring(0, 10);

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

  void _showQuoteOverlay() {
    final random = Random();
    setState(() {
      currentQuote = quotes[random.nextInt(quotes.length)];
      showQuote = true;
      quoteOpacity = 1.0;
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() => quoteOpacity = 0.0);
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() => showQuote = false);
      });
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          endDrawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue),
                  child: Text('Kaldi Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
                ),
                ListTile(
                  leading: const Icon(Icons.flag),
                  title: const Text('Markmið'),
                  onTap: () async {
                    Navigator.pop(context);
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GoalScreen()),
                    );
                    if (updated == true) {
                      _loadGoals();
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.format_quote),
                  title: const Text('Quote'),
                  onTap: () {
                    Navigator.pop(context);
                    _showQuoteOverlay();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Skoða fyrri daga'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PastDayScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Útskráning'),
                  onTap: _logout,
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 3),
                borderRadius: BorderRadius.circular(36),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 24),
                        const Text(
                          'Kaldi',
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                        Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(Icons.menu, color: Colors.blue),
                            onPressed: () => Scaffold.of(context).openEndDrawer(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CircularPercentIndicator(
                      radius: 120.0,
                      lineWidth: 16.0,
                      percent: calorieGoal > 0
                          ? (consumedCalories / calorieGoal).clamp(0.0, 1.0)
                          : 0.0,
                      center: Text(
                        "$consumedCalories / $calorieGoal\nkcal",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
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
                            Text('$consumedProtein g / $proteinGoal g', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Kolvetni'),
                            Text('$consumedCarbs g / $carbGoal g', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Fita'),
                            Text('$consumedFat g / $fatGoal g', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            const Text('Núverandi þyngd'),
                            Text('${currentWeight.toStringAsFixed(1)} kg'),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Markmið þyngd'),
                            Text('${targetWeight.toStringAsFixed(1)} kg'),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AddFoodScreen()),
                          );
                          if (result == true) {
                            _loadTodaysTotals();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Bæta við mat', style: TextStyle(fontSize: 18)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        if (showQuote)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 500),
            opacity: quoteOpacity,
            child: Container(
              color: Colors.black.withOpacity(0.6),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(24),
              child: Text(
                currentQuote,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
      ],
    );
  }
}
