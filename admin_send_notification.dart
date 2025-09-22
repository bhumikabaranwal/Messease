import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class AdminSendNotification extends StatefulWidget {
  const AdminSendNotification({super.key});

  @override
  State<AdminSendNotification> createState() => _AdminSendNotificationState();
}

class _AdminSendNotificationState extends State<AdminSendNotification> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Notification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(labelText: 'Message'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendNotification,
              child: const Text('Send to All Students'),
            ),
          ],
        ),
      ),
    );
  }

  void _sendNotification() async {
    await _notificationService.sendNotification(
      title: _titleController.text,
      body: _bodyController.text,
    );
    Navigator.pop(context);
  }
}