import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminComplaints extends StatelessWidget {
  const AdminComplaints({super.key});

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
          "Student Complaints",
          style: TextStyle(
            color: Color(0xFF1A2980),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('complaints')
            .orderBy('createdAt', descending: true)
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
                'Error loading complaints',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          final complaints = snapshot.data?.docs ?? [];

          if (complaints.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_rounded,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No complaints yet',
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
            padding: EdgeInsets.all(16),
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final complaint =
                  complaints[index].data() as Map<String, dynamic>;
              final timestamp = complaint['createdAt'] as Timestamp?;
              final date = timestamp != null
                  ? DateFormat('MMM d, yyyy • h:mm a')
                      .format(timestamp.toDate())
                  : 'Date not available';

              return Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Color(0xFF1A2980).withOpacity(0.1),
                            child: Icon(
                              Icons.person_outline,
                              color: Color(0xFF1A2980),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Anonymous Student',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Complaint #${complaints[index].id.substring(0, 8)}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: complaint['status'] == 'pending'
                                  ? Colors.orange.withOpacity(0.2)
                                  : Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              complaint['status']?.toUpperCase() ?? 'PENDING',
                              style: TextStyle(
                                color: complaint['status'] == 'pending'
                                    ? Colors.orange[700]
                                    : Colors.green[700],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          complaint['complaint'] ?? 'No complaint text',
                          style: TextStyle(
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            date,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          if (complaint['status'] == 'pending')
                            TextButton.icon(
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('complaints')
                                    .doc(complaints[index].id)
                                    .update({'status': 'resolved'});
                              },
                              icon: Icon(
                                Icons.check_circle_outline,
                                size: 18,
                                color: Colors.green,
                              ),
                              label: Text(
                                'Mark as Resolved',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
