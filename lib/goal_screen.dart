import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:calorie_counter/home_screen.dart';


class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  final _formKey = GlobalKey<FormState>();

  final weightController = TextEditingController();
  final targetWeightController = TextEditingController();
  final calorieController = TextEditingController();
  final proteinController = TextEditingController();
  final carbController = TextEditingController();
  final fatController = TextEditingController();

  @override
  void dispose() {
    weightController.dispose();
    targetWeightController.dispose();
    calorieController.dispose();
    proteinController.dispose();
    carbController.dispose();
    fatController.dispose();
    super.dispose();
  }

  void saveGoals() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final uid = user.uid;

      await FirebaseFirestore.instance.collection('goals').doc(uid).set({
        'currentWeight': double.parse(weightController.text),
        'targetWeight': double.parse(targetWeightController.text),
        'calories': int.parse(calorieController.text),
        'protein': int.parse(proteinController.text),
        'carbs': int.parse(carbController.text),
        'fat': int.parse(fatController.text),
        'updatedAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Markmið vistuð!")),
      );

      Navigator.pop(context, true);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Markmið'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildField("Núverandi þyngd (kg)", weightController),
              _buildField("Markmiðs þyngd (kg)", targetWeightController),
              _buildField("Hitaeiningar á dag", calorieController),
              _buildField("Prótein (g)", proteinController),
              _buildField("Kolvetni (g)", carbController),
              _buildField("Fita (g)", fatController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveGoals,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text("Vista markmið"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        ],
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
        value == null || value.isEmpty ? "Fylltu þetta út" : null,
      ),

    );
  }
}
