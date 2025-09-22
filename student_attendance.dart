import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class StudentAttendance extends StatefulWidget {
  const StudentAttendance({super.key});

  @override
  State<StudentAttendance> createState() => _StudentAttendanceState();
}

class _StudentAttendanceState extends State<StudentAttendance> {
  bool _isLoading = false;
  String _selectedMeal = 'breakfast';
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  int _optOutCount = 0;

  // Define cut-off times for each meal
  final Map<String, TimeOfDay> _mealCutoffTimes = {
    'breakfast': TimeOfDay(hour: 22, minute: 0), // 7:00 AM
    'lunch': TimeOfDay(hour: 22, minute: 0), // 10:00 AM
    'dinner': TimeOfDay(hour: 22, minute: 0), // 4:00 PM
  };

  @override
  void initState() {
    super.initState();
    _loadOptOutCount();
    _setInitialMeal();
  }

  void _setInitialMeal() {
    final now = TimeOfDay.now();
    if (now.hour < 10) {
      _selectedMeal = 'breakfast';
    } else if (now.hour < 16) {
      _selectedMeal = 'lunch';
    } else {
      _selectedMeal = 'dinner';
    }
    setState(() {});
  }

  Future<void> _loadOptOutCount() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final optOuts = await _firestore
        .collection('attendance')
        .where('date', isEqualTo: Timestamp.fromDate(today))
        .where('meal', isEqualTo: _selectedMeal)
        .where('isOptOut', isEqualTo: true)
        .get();

    setState(() {
      _optOutCount = optOuts.docs.length;
    });
  }

  bool _isMealCutoffPassed(String meal) {
    final cutoffTime = _mealCutoffTimes[meal]!;
    final now = TimeOfDay.now();

    return (now.hour > cutoffTime.hour) ||
        (now.hour == cutoffTime.hour && now.minute > cutoffTime.minute);
  }

  Future<void> _markAttendance({bool isOptOut = false}) async {
    if (_isMealCutoffPassed(_selectedMeal)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cut-off time passed for ${_selectedMeal}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() as Map<String, dynamic>;

      // Check if already marked for this meal today
      final existingAttendance = await _firestore
          .collection('attendance')
          .where('userId', isEqualTo: user.uid)
          .where('date', isEqualTo: Timestamp.fromDate(today))
          .where('meal', isEqualTo: _selectedMeal)
          .get();

      if (existingAttendance.docs.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Already marked for ${_selectedMeal} today'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Mark attendance
      await _firestore.collection('attendance').add({
        'userId': user.uid,
        'studentName': userData['name'],
        'rollNumber': userData['rollNumber'],
        'meal': _selectedMeal,
        'date': Timestamp.fromDate(today),
        'markedAt': FieldValue.serverTimestamp(),
        'isOptOut': isOptOut,
      });

      // Update opt-out count
      await _loadOptOutCount();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isOptOut
                ? 'Successfully opted out of ${_selectedMeal}'
                : 'Attendance marked for ${_selectedMeal}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF1A2980)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Mark Attendance",
          style: TextStyle(
            color: Color(0xFF1A2980),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Card
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF1A2980).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Date:',
                    style: TextStyle(
                      color: Color(0xFF1A2980),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                    style: TextStyle(
                      color: Color(0xFF1A2980).withOpacity(0.8),
                      fontSize: 18,
                    ),
                  ),
                  Divider(
                      height: 24, color: Color(0xFF1A2980).withOpacity(0.2)),
                  Text(
                    'Students Opting Out:',
                    style: TextStyle(
                      color: Color(0xFF1A2980),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '$_optOutCount students not eating',
                    style: TextStyle(
                      color: Color(0xFF1A2980).withOpacity(0.8),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Meal Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Meal:',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Cut-off: ${_mealCutoffTimes[_selectedMeal]!.format(context)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  _buildMealOption(
                      'breakfast', 'Breakfast', Icons.breakfast_dining),
                  Divider(height: 1),
                  _buildMealOption('lunch', 'Lunch', Icons.lunch_dining),
                  Divider(height: 1),
                  _buildMealOption('dinner', 'Dinner', Icons.dinner_dining),
                ],
              ),
            ),
            SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => _markAttendance(isOptOut: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Not Eating Today',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                               color: Colors.white,
                            ),
                          ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _markAttendance(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1A2980),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Mark Attendance',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                               color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealOption(String value, String title, IconData icon) {
    final isCutoffPassed = _isMealCutoffPassed(value);

    return RadioListTile<String>(
      value: value,
      groupValue: _selectedMeal,
      onChanged: isCutoffPassed
          ? null
          : (value) {
              setState(() => _selectedMeal = value!);
              _loadOptOutCount();
            },
      title: Row(
        children: [
          Icon(
            icon,
            color: isCutoffPassed ? Colors.grey : Color(0xFF1A2980),
          ),
          SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: isCutoffPassed ? Colors.grey : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isCutoffPassed) ...[
            SizedBox(width: 8),
            Text(
              '(Cut-off passed)',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
      activeColor: Color(0xFF1A2980),
      contentPadding: EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
