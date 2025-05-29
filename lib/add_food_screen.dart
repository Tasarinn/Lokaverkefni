import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> with SingleTickerProviderStateMixin {
  bool _showOverlay = false;
  double _overlayOpacity = 0.0;
  final _searchController = TextEditingController();
  final List<Map<String, dynamic>> _selectedFoods = [];
  bool _hasTyped = false;

  late AnimationController _cartController;
  late Animation<double> _cartScale;

  final List<Map<String, dynamic>> _foodDatabase = [
    {'name': 'Kjúklingur', 'calories': 165, 'protein': 31, 'carbs': 0, 'fat': 3.6},
    {'name': 'Egg', 'calories': 155, 'protein': 13, 'carbs': 1.1, 'fat': 11},
    {'name': 'Avókadó', 'calories': 160, 'protein': 2, 'carbs': 9, 'fat': 15},
    {'name': 'Hrísgrjón', 'calories': 130, 'protein': 2.7, 'carbs': 28, 'fat': 0.3},
    {'name': 'Bananar', 'calories': 89, 'protein': 1.1, 'carbs': 23, 'fat': 0.3},
    {'name': 'Brokkolí', 'calories': 55, 'protein': 3.7, 'carbs': 11.2, 'fat': 0.6},
    {'name': 'Kotasæla', 'calories': 98, 'protein': 11, 'carbs': 3.4, 'fat': 4.3},
  ];

  List<Map<String, dynamic>> get _filteredFoods {
    final query = _searchController.text.toLowerCase().replaceAll('í', 'i').replaceAll('á', 'a').replaceAll('ú', 'u').replaceAll('ð', 'd');
    return _foodDatabase.where((food) {
      final name = food['name'].toLowerCase().replaceAll('í', 'i').replaceAll('á', 'a').replaceAll('ú', 'u').replaceAll('ð', 'd');
      return name.contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _cartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      lowerBound: 0.8,
      upperBound: 1.0,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _cartController.reverse();
      }
    });
    _cartScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _cartController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _cartController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _promptGramsAndAddFood(Map<String, dynamic> food) async {
    final controller = TextEditingController();

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hversu mikið af ${food['name']}?'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Gramm', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            child: const Text('Hætta'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Bæta við'),
            onPressed: () {
              final grams = double.tryParse(controller.text);
              Navigator.pop(context, grams);
            },
          ),
        ],
      ),
    );

    if (result != null && result > 0) {
      final factor = result / 100.0;
      final entry = {
        'name': food['name'],
        'calories': (food['calories'] * factor).round(),
        'protein': (food['protein'] * factor).round(),
        'carbs': (food['carbs'] * factor).round(),
        'fat': (food['fat'] * factor).round(),
      };

      setState(() {
        _selectedFoods.add(entry);
        _searchController.clear();
        _hasTyped = false;
      });

      print("Triggering cart animation...");
      _cartController.forward(from: 0.8);

      setState(() {
        _showOverlay = true;
        _overlayOpacity = 1.0;
      });

      Future.delayed(const Duration(seconds: 2), () {
        setState(() => _overlayOpacity = 0.0);
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() => _showOverlay = false);
        });
      });
    }
  }

  Future<void> _saveEntries() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final dateKey = now.toIso8601String().substring(0, 10);

    final docRef = FirebaseFirestore.instance
        .collection('foodLogs')
        .doc(user.uid)
        .collection('days')
        .doc(dateKey);

    final entries = _selectedFoods.map((e) => {
      'name': e['name'],
      'calories': e['calories'],
      'protein': e['protein'],
      'carbs': e['carbs'],
      'fat': e['fat'],
      'timestamp': Timestamp.now(),
    }).toList();

    await docRef.set({
      'entries': FieldValue.arrayUnion(entries),
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    final pageContext = context;
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Bæta við mat'),
            actions: [
              ScaleTransition(
                scale: _cartScale,
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () => _showCart(),
                ),
              ),
            ],
          ),
          body: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 3),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Leitaðu að mat',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _hasTyped = value.trim().isNotEmpty;
                    });
                  },
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _hasTyped
                      ? ListView.builder(
                    itemCount: _filteredFoods.length,
                    itemBuilder: (context, index) {
                      final food = _filteredFoods[index];
                      return ListTile(
                        title: Text(food['name']),
                        onTap: () => _promptGramsAndAddFood(food),
                      );
                    },
                  )
                      : const Center(child: Text('Byrjaðu að skrifa til að sjá mat.')),
                ),
              ],
            ),
          ),
        ),
        if (_showOverlay)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _overlayOpacity,
            child: Container(
              color: Colors.black.withOpacity(0.6),
              alignment: Alignment.center,
              child: const Text(
                'Bætt í körfu!',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showCart() {
    final outerContext = context;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Karfa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const Divider(),
            if (_selectedFoods.isEmpty)
              const Text('Enginn matur valinn.')
            else
              ..._selectedFoods.map((e) => ListTile(
                title: Text(e['name']),
                subtitle: Text(
                  'Hitaeiningar: ${e['calories']} - Prótein: ${e['protein']}g - Kolvetni: ${e['carbs']}g - Fita: ${e['fat']}g',
                ),
              )),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _saveEntries();
                Navigator.pop(context); // Close bottom sheet
                Navigator.pop(outerContext, true); // Close AddFoodScreen using outer context
              },
              child: const Text('Vista'),
            ),
          ],
        ),
      ),
    );
  }
}
