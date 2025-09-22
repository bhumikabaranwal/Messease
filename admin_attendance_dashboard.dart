import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminAttendanceDashboard extends StatelessWidget {
  const AdminAttendanceDashboard({super.key});

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
          "Attendance Dashboard",
          style: TextStyle(
            color: Color(0xFF1A2980),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'student')
            .snapshots(),
        builder: (context, studentSnapshot) {
          if (studentSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final totalStudents = studentSnapshot.data?.docs.length ?? 0;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('attendance')
                .where('date',
                    isEqualTo: Timestamp.fromDate(
                      DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        DateTime.now().day,
                      ),
                    ))
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              final attendanceRecords = snapshot.data?.docs ?? [];

              // Calculate statistics for each meal
              final stats = {
                'breakfast': _calculateMealStats(
                    attendanceRecords, 'breakfast', totalStudents),
                'lunch': _calculateMealStats(
                    attendanceRecords, 'lunch', totalStudents),
                'dinner': _calculateMealStats(
                    attendanceRecords, 'dinner', totalStudents),
              };

              return SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard(totalStudents),
                    SizedBox(height: 24),
                    Text(
                      "Today's Meal Statistics",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A2980),
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildMealCard('Breakfast', stats['breakfast']!,
                        Icons.breakfast_dining),
                    SizedBox(height: 16),
                    _buildMealCard(
                        'Lunch', stats['lunch']!, Icons.lunch_dining),
                    SizedBox(height: 16),
                    _buildMealCard(
                        'Dinner', stats['dinner']!, Icons.dinner_dining),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(int totalStudents) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A2980), Color(0xFF26D0CE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Total Students: $totalStudents',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(
      String meal, Map<String, dynamic> stats, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Color(0xFF1A2980), size: 24),
              SizedBox(width: 12),
              Text(
                meal,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2980),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Opt-outs',
                  stats['optOuts'].toString(),
                  '${stats['optOutPercentage']}%',
                  Colors.red,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Attending',
                  stats['attending'].toString(),
                  '${stats['attendingPercentage']}%',
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String count, String percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        SizedBox(height: 4),
        Row(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(width: 8),
            Text(
              percentage,
              style: TextStyle(
                fontSize: 16,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Map<String, dynamic> _calculateMealStats(
    List<QueryDocumentSnapshot> records,
    String meal,
    int totalStudents,
  ) {
    final mealRecords = records.where((doc) => doc['meal'] == meal);
    final optOuts = mealRecords.where((doc) => doc['isOptOut'] == true).length;
    final attending =
        mealRecords.where((doc) => doc['isOptOut'] == false).length;

    final optOutPercentage =
        totalStudents > 0 ? ((optOuts / totalStudents) * 100).round() : 0;
    final attendingPercentage =
        totalStudents > 0 ? ((attending / totalStudents) * 100).round() : 0;

    return {
      'optOuts': optOuts,
      'attending': attending,
      'optOutPercentage': optOutPercentage,
      'attendingPercentage': attendingPercentage,
    };
  }
}
