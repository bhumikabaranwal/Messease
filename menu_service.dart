import 'package:cloud_firestore/cloud_firestore.dart';

class MenuService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> initializeMenuData() async {
    // Sample menu data for each day
    final Map<String, Map<String, List<String>>> weeklyMenu = {
      'monday': {
        'Breakfast': [
          'Poha',
          'Boiled Eggs',
          'Bread Toast',
          'Tea/Coffee',
          'Milk'
        ],
        'Lunch': ['Rice', 'Dal Fry', 'Mix Veg', 'Chapati', 'Salad', 'Curd'],
        'Snacks': ['Samosa', 'Tea/Coffee', 'Biscuits'],
        'Dinner': ['Rice', 'Dal Tadka', 'Paneer Curry', 'Chapati', 'Sweet']
      },
      'tuesday': {
        'Breakfast': ['Idli Sambar', 'Coconut Chutney', 'Tea/Coffee', 'Milk'],
        'Lunch': [
          'Rice',
          'Rajma',
          'Aloo Gobi',
          'Chapati',
          'Salad',
          'Buttermilk'
        ],
        'Snacks': ['Vada Pav', 'Tea/Coffee', 'Cookies'],
        'Dinner': ['Rice', 'Dal Makhani', 'Mix Veg', 'Chapati', 'Ice Cream']
      },
      'wednesday': {
        'Breakfast': ['Upma', 'Boiled Eggs', 'Bread Jam', 'Tea/Coffee', 'Milk'],
        'Lunch': ['Rice', 'Dal', 'Bhindi Masala', 'Chapati', 'Salad', 'Raita'],
        'Snacks': ['Bread Pakoda', 'Tea/Coffee', 'Namkeen'],
        'Dinner': ['Rice', 'Dal', 'Chicken/Paneer Curry', 'Chapati', 'Kheer']
      },
      'thursday': {
        'Breakfast': ['Puri Bhaji', 'Boiled Eggs', 'Tea/Coffee', 'Milk'],
        'Lunch': ['Rice', 'Dal', 'Chole', 'Chapati', 'Salad', 'Curd'],
        'Snacks': ['Pasta', 'Tea/Coffee', 'Biscuits'],
        'Dinner': ['Rice', 'Dal', 'Egg/Veg Curry', 'Chapati', 'Gulab Jamun']
      },
      'friday': {
        'Breakfast': ['Dosa', 'Sambar', 'Chutney', 'Tea/Coffee', 'Milk'],
        'Lunch': [
          'Rice',
          'Dal',
          'Aloo Matar',
          'Chapati',
          'Salad',
          'Buttermilk'
        ],
        'Snacks': ['Cutlet', 'Tea/Coffee', 'Cookies'],
        'Dinner': ['Rice', 'Dal', 'Mushroom/Paneer', 'Chapati', 'Fruit Custard']
      },
      'saturday': {
        'Breakfast': ['Paratha', 'Curd', 'Boiled Eggs', 'Tea/Coffee', 'Milk'],
        'Lunch': ['Rice', 'Dal', 'Kadai Veg', 'Chapati', 'Salad', 'Raita'],
        'Snacks': ['Bhel Puri', 'Tea/Coffee', 'Namkeen'],
        'Dinner': ['Rice', 'Dal', 'Malai Kofta', 'Chapati', 'Halwa']
      },
      'sunday': {
        'Breakfast': ['Chole Bhature', 'Boiled Eggs', 'Tea/Coffee', 'Milk'],
        'Lunch': ['Rice', 'Dal', 'Veg Biryani', 'Raita', 'Salad', 'Papad'],
        'Snacks': ['Pav Bhaji', 'Tea/Coffee', 'Biscuits'],
        'Dinner': ['Rice', 'Dal', 'Shahi Paneer', 'Chapati', 'Rasmalai']
      }
    };

    // Create a batch write operation
    final WriteBatch batch = _firestore.batch();

    // Add menu data for each day
    weeklyMenu.forEach((day, menuData) {
      DocumentReference dayRef = _firestore.collection('menu').doc(day);
      batch.set(dayRef, menuData, SetOptions(merge: true));
    });

    // Commit the batch
    try {
      await batch.commit();
      print('Menu data initialized successfully');
    } catch (e) {
      print('Error initializing menu data: $e');
    }
  }
}
