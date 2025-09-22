import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminMenuEditor extends StatefulWidget {
  const AdminMenuEditor({super.key});

  @override
  State<AdminMenuEditor> createState() => _AdminMenuEditorState();
}

class _AdminMenuEditorState extends State<AdminMenuEditor> {
  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  final List<String> meals = ['Breakfast', 'Lunch', 'Snacks', 'Dinner'];
  String selectedDay = 'Monday';
  String selectedMeal = 'Breakfast';
  List<String> currentItems = [];
  TextEditingController itemController = TextEditingController();

  final Color primaryColor = Color(0xFF1A2980);
  final Color secondaryColor = Color(0xFF26D0CE); // Accent
  final Color inputBg = Colors.white.withOpacity(0.1);

  @override
  void initState() {
    super.initState();
    loadMenuItems();
  }

  Future<void> loadMenuItems() async {
    DocumentSnapshot menuDoc = await FirebaseFirestore.instance
        .collection('menu')
        .doc(selectedDay.toLowerCase())
        .get();

    if (menuDoc.exists) {
      Map<String, dynamic> menuData = menuDoc.data() as Map<String, dynamic>;
      setState(() {
        currentItems = List<String>.from(menuData[selectedMeal] ?? []);
      });
    }
  }

  Future<void> saveMenuItems() async {
    try {
      DocumentReference menuRef = FirebaseFirestore.instance
          .collection('menu')
          .doc(selectedDay.toLowerCase());

      DocumentSnapshot menuDoc = await menuRef.get();
      Map<String, dynamic> menuData = {};

      if (menuDoc.exists) {
        menuData = menuDoc.data() as Map<String, dynamic>;
      }

      menuData[selectedMeal] = currentItems;

      await menuRef.set(menuData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Menu updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating menu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void addItem() {
    if (itemController.text.isNotEmpty) {
      setState(() {
        currentItems.add(itemController.text);
        itemController.clear();
      });
    }
  }

  void removeItem(int index) {
    setState(() {
      currentItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryColor,
              secondaryColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      "Edit Menu",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.save, color: Colors.white),
                      onPressed: saveMenuItems,
                      tooltip: 'Save Changes',
                    ),
                  ],
                ),
              ),

              // Dropdowns
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: dropdownWrapper(
                        value: selectedDay,
                        items: days,
                        onChanged: (val) {
                          setState(() {
                            selectedDay = val!;
                            loadMenuItems();
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: dropdownWrapper(
                        value: selectedMeal,
                        items: meals,
                        onChanged: (val) {
                          setState(() {
                            selectedMeal = val!;
                            loadMenuItems();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Add item
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: inputBg,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: TextField(
                          controller: itemController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Add new item...',
                            hintStyle: TextStyle(color: Colors.white70),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 15),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.pinkAccent,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.add, color: Colors.white),
                        onPressed: addItem,
                      ),
                    ),
                  ],
                ),
              ),

              // List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  itemCount: currentItems.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: inputBg,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: ListTile(
                        title: Text(
                          currentItems[index],
                          style: TextStyle(color: Colors.white),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.white70),
                          onPressed: () => removeItem(index),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget dropdownWrapper({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        dropdownColor: primaryColor,
        style: TextStyle(color: Colors.white),
        underline: Container(),
        iconEnabledColor: Colors.white,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
