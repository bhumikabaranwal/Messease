import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/notification_service.dart';

class StudentNotifications extends StatelessWidget {
  final NotificationService _notificationService = NotificationService();

  StudentNotifications({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _notificationService.getNotifications(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading notifications'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['title']),
                subtitle: Text(data['body']),
                trailing: data['read'] 
                    ? null 
                    : const Icon(Icons.brightness_1, color: Colors.red, size: 12),
                onTap: () => _markAsRead(doc.id),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _markAsRead(String docId) {
    FirebaseFirestore.instance
        .collection('notifications')
        .doc(docId)
        .update({'read': true});
  }
}