import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  Future<List<String>> _getUnpaidMonths(String userId) async {
    final now = DateTime.now();
    final currentYear = now.year;
    final List<String> months = [];

    // Get all payments for current year
    final paymentsSnapshot = await _firestore
        .collection('payments')
        .where('userId', isEqualTo: userId)
        .where('year', isEqualTo: currentYear)
        .get();

    // Create a set of paid months
    final paidMonths = paymentsSnapshot.docs.map((doc) {
      final data = doc.data();
      return data['month'] as int;
    }).toSet();

    // Check months from January until current month
    for (int month = 1; month <= now.month; month++) {
      if (!paidMonths.contains(month)) {
        months.add(DateFormat('MMMM').format(DateTime(currentYear, month)));
      }
    }

    return months;
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
          "Student Records",
          style: TextStyle(
            color: Color(0xFF1A2980),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Summary Card
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A2980), Color(0xFF26D0CE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .where('role', isEqualTo: 'student')
                  .snapshots(),
              builder: (context, snapshot) {
                int totalStudents = snapshot.data?.docs.length ?? 0;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Students',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '$totalStudents',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .where('role', isEqualTo: 'student')
                  .snapshots(),
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
                      'Error loading student data',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                final students = snapshot.data?.docs ?? [];

                if (students.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No students registered yet',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student =
                        students[index].data() as Map<String, dynamic>;
                    final studentId = students[index].id;

                    return FutureBuilder<List<String>>(
                      future: _getUnpaidMonths(studentId),
                      builder: (context, unpaidSnapshot) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  Color(0xFF1A2980).withOpacity(0.1),
                              child: Text(
                                student['name']?[0].toUpperCase() ?? 'S',
                                style: TextStyle(
                                  color: Color(0xFF1A2980),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              student['name'] ?? 'No Name',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              student['email'] ?? 'No Email',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: unpaidSnapshot.hasData &&
                                    unpaidSnapshot.data!.isNotEmpty
                                ? Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${unpaidSnapshot.data!.length} dues',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : null,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (student['rollNumber'] != null) ...[
                                      _buildDetailRow(
                                        Icons.numbers,
                                        'Roll Number',
                                        student['rollNumber'],
                                      ),
                                      Divider(height: 24),
                                    ],
                                    if (student['roomNumber'] != null) ...[
                                      _buildDetailRow(
                                        Icons.meeting_room,
                                        'Room',
                                        student['roomNumber'],
                                      ),
                                      Divider(height: 24),
                                    ],
                                    if (unpaidSnapshot.hasData &&
                                        unpaidSnapshot.data!.isNotEmpty) ...[
                                      Text(
                                        'Pending Dues:',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children:
                                            unpaidSnapshot.data!.map((month) {
                                          return Chip(
                                            label: Text(month),
                                            backgroundColor:
                                                Colors.red.withOpacity(0.1),
                                            labelStyle: TextStyle(
                                              color: Colors.red,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ] else ...[
                                      Text(
                                        'No pending dues',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                    SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        // Handle payment action
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF1A2980),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        minimumSize: Size(double.infinity, 48),
                                      ),
                                      child: Text(
                                        'Record Payment',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Color(0xFF1A2980),
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
