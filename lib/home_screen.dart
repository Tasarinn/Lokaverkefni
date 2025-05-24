import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'dart:math';
import 'package:calorie_counter/goal_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:calorie_counter/add_food_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  bool showQuote = false;
  int calorieGoal = 0;
  int proteinGoal = 0;
  int carbGoal = 0;
  int fatGoal = 0;

  bool loadingGoals = true;

  void _handleMenu(String value) async {
    switch (value) {
      case 'logout':
        FirebaseAuth.instance.signOut();
        Navigator.pop(context);
        break;
      case 'quote':
        _showQuoteOverlay();
        break;
      case 'goals':
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GoalScreen()),
        );

        if (result == true) {
          _loadGoals();
        }
        break;

    }
  }
  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  void _loadGoals() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('goals')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        calorieGoal = data['calories'] ?? 0;
        proteinGoal = data['protein'] ?? 0;
        carbGoal = data['carbs'] ?? 0;
        fatGoal = data['fat'] ?? 0;
        loadingGoals = false;
      });
    } else {
      setState(() {
        loadingGoals = false;
      });
    }
  }

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
    "When you want to succeed as bad as you want to breathe, then you’ll be successful. – Eric Thomas",
    "Shut up and squat.",
    "I don't eat for taste. I eat for function. – Kai Greene",
    "There’s no off-season.",
    "Weakness leaves the body through sweat and tears.",
    "If you're not training to failure, you're training to fail.",
    "A one-hour workout is 4% of your day. No excuses.",
    "Muscles are earned, not gifted.",
    "The wolf on the hill is not as hungry as the wolf climbing the hill. – Arnold Schwarzenegger",
    "Shut up. Train harder.",
    "You don’t grow in comfort. You grow in pain.",
    "Don’t be a bitch. Hit your set.",
    "Some people dream of success. Others wake up and lift heavy shit.",
    "Train insane or remain the same.",
    "Excuses don’t burn calories.",
    "Real strength is built when nobody's watching.",
    "Sweat is just fat crying.",
    "If it doesn’t challenge you, it doesn’t change you.",
    "Obsessed is a word the lazy use to describe the dedicated.",
    "I don’t need pre-workout. I think about my enemies.",
    "Comfort is the enemy of progress.",
    "Beast mode isn’t a button. It’s a lifestyle.",
    "The iron never lies. – Henry Rollins",
    "Every rep gets me closer to god-status.",
    "You rest. I reload.",
    "Don't expect results from work you didn’t do.",
    "Your body hears everything your mind says. Stop saying bullshit.",
    "Mirrors don’t lie – but your excuses do.",
    "My warm-up is your max.",
    "I’ll stop when I’m done, not when I’m tired.",
    "Size matters – especially when it's earned.",
    "You train for aesthetics. I train for dominance.",
    "Weights don’t lift themselves – neither will your life.",
    "Haters watch. Champions train.",
    "Muscles are built when weakness is broken repeatedly.",
    "The gym is therapy. The barbell is truth.",
    "I’ve never met a strong person with an easy past.",
    "Biceps win races, triceps win wars. – Greg Plitt",
    "Be more than human. – CT Fletcher",
    "You don’t need motivation. You need discipline."
  ];
  String currentQuote = "";

  double quoteOpacity = 0.0;


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


  @override
  Widget build(BuildContext context) {
    if (loadingGoals) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    final user = FirebaseAuth.instance.currentUser;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
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
                    // Header Row with menu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 24), // Keeps Kaldi centered
                        const Text(
                          'Kaldi',
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                        PopupMenuButton<String>(
                          onSelected: _handleMenu,
                          icon: const Icon(Icons.menu, color: Colors.blue),
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'logout', child: Text('Útskráning')),
                            const PopupMenuItem(value: 'goals', child: Text('Markmið')),
                            const PopupMenuItem(value: 'quote', child: Text('Quote')),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    if (loadingGoals)
                      const CircularProgressIndicator()
                    else
                      Column(
                        children: [
                          CircularPercentIndicator(
                            radius: 120.0,
                            lineWidth: 16.0,
                            percent: 0.0, // still placeholder for calories consumed / goal
                            center: Text(
                              "0 / $calorieGoal\nkcal",
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
                                  Text('0g / $proteinGoal',
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text('Kolvetni'),
                                  Text('0g / $carbGoal',
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text('Fita'),
                                  Text('0g / $fatGoal',
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),

                    const SizedBox(height: 20),
                    const Spacer(),
                      // Add food button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (context) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.search),
                                  title: const Text('Bæta við vöru'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    // TODO: Open Krónan product screen
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.rice_bowl),
                                  title: const Text('Bæta við mat'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const AddFoodScreen()),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
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
                  ]
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
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: currentQuote,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none, // <- this disables underlines
                  ),
                ),
              ),
            ),
          )
      ],
    );
  }
}
