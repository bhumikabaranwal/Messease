import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WeeklyMenuPage extends StatefulWidget {
  const WeeklyMenuPage({super.key});

  @override
  State<WeeklyMenuPage> createState() => _WeeklyMenuPageState();
}

class _WeeklyMenuPageState extends State<WeeklyMenuPage> {
  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  String selectedDay = 'Monday';

  final Map<String, String> _mealImages = {
    'Breakfast': 'assets/breakfast.png',
    'Lunch': 'assets/lunch.jpg',
    'Snacks': 'assets/snacks.jpeg',
    'Dinner': 'assets/dinner.jpeg',
  };

  Future<Map<String, List<String>>> _loadDayMenu(String day) async {
    Map<String, List<String>> menuData = {
      'Breakfast': [],
      'Lunch': [],
      'Snacks': [],
      'Dinner': []
    };

    try {
      DocumentSnapshot menuDoc = await FirebaseFirestore.instance
          .collection('menu')
          .doc(day.toLowerCase())
          .get();

      if (menuDoc.exists) {
        Map<String, dynamic> data = menuDoc.data() as Map<String, dynamic>;
        menuData['Breakfast'] = List<String>.from(data['Breakfast'] ?? []);
        menuData['Lunch'] = List<String>.from(data['Lunch'] ?? []);
        menuData['Snacks'] = List<String>.from(data['Snacks'] ?? []);
        menuData['Dinner'] = List<String>.from(data['Dinner'] ?? []);
      }
    } catch (e) {
      print('Error loading menu: $e');
    }

    return menuData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF1A2980)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Weekly Menu",
          style: TextStyle(
            color: Color(0xFF1A2980),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Day Selection
          Container(
            height: 70,
            padding: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              itemBuilder: (context, index) {
                bool isSelected = days[index] == selectedDay;
                return Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 16 : 0, right: 8),
                  child: ChoiceChip(
                    label: Text(
                      days[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Color(0xFF1A2980),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedDay = days[index];
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: Color(0xFF1A2980),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSelected 
                            ? Colors.transparent 
                            : Color(0xFF1A2980).withOpacity(0.2),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Menu Content
          Expanded(
            child: FutureBuilder<Map<String, List<String>>>(
              future: _loadDayMenu(selectedDay),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF1A2980),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading menu',
                      style: TextStyle(color: Color(0xFF1A2980)),
                    ),
                  );
                }

                Map<String, List<String>> menuData = snapshot.data ??
                    {'Breakfast': [], 'Lunch': [], 'Snacks': [], 'Dinner': []};

                return ListView(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                  children: [
                    _buildMealCard('Breakfast', menuData['Breakfast']!),
                    _buildMealCard('Lunch', menuData['Lunch']!),
                    _buildMealCard('Snacks', menuData['Snacks']!),
                    _buildMealCard('Dinner', menuData['Dinner']!),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(String meal, List<String> items) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Meal Image with Title Overlay
          Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(_mealImages[meal]!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getMealIcon(meal),
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      meal,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Menu Items
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.isEmpty
                  ? [
                      Center(
                        child: Text(
                          'No items available',
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    ]
                  : items.map((item) => _buildMenuItem(item)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMealIcon(String meal) {
    switch (meal) {
      case 'Breakfast': return Icons.free_breakfast;
      case 'Lunch': return Icons.lunch_dining;
      case 'Snacks': return Icons.bakery_dining;
      case 'Dinner': return Icons.dinner_dining;
      default: return Icons.restaurant;
    }
  }

  Widget _buildMenuItem(String item) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(0xFF26D0CE),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: Colors.white, size: 12),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              item,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}