import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final calorieController = TextEditingController();
  final proteinController = TextEditingController();
  final carbController = TextEditingController();
  final fatController = TextEditingController();

  @override
  void dispose() {
    calorieController.dispose();
    proteinController.dispose();
    carbController.dispose();
    fatController.dispose();
    super.dispose();
  }

  Future<void> saveFoodEntry() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final dateKey = "${now.year}-${now.month}-${now.day}";

    final foodEntry = {
      'calories': int.parse(calorieController.text),
      'protein': int.parse(proteinController.text),
      'carbs': int.parse(carbController.text),
      'fat': int.parse(fatController.text),
      'timestamp': Timestamp.now(),
    };

    final docRef = FirebaseFirestore.instance
        .collection('foodLogs')
        .doc(user.uid)
        .collection('days')
        .doc(dateKey);

    await docRef.set({
      'entries': FieldValue.arrayUnion([foodEntry]),
    }, SetOptions(merge: true));

    Navigator.pop(context, true); // Return true to trigger refresh
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bæta við mat'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildField("Hitaeiningar", calorieController),
              _buildField("Prótein (g)", proteinController),
              _buildField("Kolvetni (g)", carbController),
              _buildField("Fita (g)", fatController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveFoodEntry,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text("Vista"),
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
        keyboardType: TextInputType.number,
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
