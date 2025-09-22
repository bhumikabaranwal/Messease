import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  Future<List<Map<String, dynamic>>> _loadAllPayments() async {
    final user = _auth.currentUser;
    List<Map<String, dynamic>> payments = [];

    if (user != null) {
      // Create payment data for all months of the current year
      for (int month = 1; month <= 12; month++) {
        final date = DateTime(DateTime.now().year, month);
        final monthYear = DateFormat('MMMM').format(date);

        try {
          DocumentSnapshot paymentDoc = await _firestore
              .collection('payments')
              .doc(user.uid)
              .collection('monthly_payments')
              .doc(monthYear)
              .get();

          Map<String, dynamic> paymentData;
          if (paymentDoc.exists) {
            paymentData = paymentDoc.data() as Map<String, dynamic>;
          } else {
            // Create default payment data for the month
            paymentData = {
              'amount': 3000,
              'month': monthYear,
              'status': 'unpaid',
              'dueDate':
                  Timestamp.fromDate(DateTime(DateTime.now().year, month, 5)),
              'createdAt': Timestamp.fromDate(DateTime.now()),
            };

            // Only create documents for current and future months
            if (date.isAfter(
                DateTime(DateTime.now().year, DateTime.now().month - 1))) {
              await _firestore
                  .collection('payments')
                  .doc(user.uid)
                  .collection('monthly_payments')
                  .doc(monthYear)
                  .set(paymentData);
            }
          }
          payments.add(paymentData);
        } catch (e) {
          print('Error loading payment for $monthYear: $e');
        }
      }
    }
    return payments;
  }

  Future<void> _processPayment(String monthYear) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('payments')
            .doc(user.uid)
            .collection('monthly_payments')
            .doc(monthYear)
            .update({
          'status': 'paid',
          'paidAt': Timestamp.fromDate(DateTime.now()),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment successful!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
          "Monthly Payments",
          style: TextStyle(
            color: Color(0xFF1A2980),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadAllPayments(),
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
                'Error loading payments',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          final payments = snapshot.data ?? [];

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index];
              final bool isPaid = payment['status'] == 'paid';
              final dueDate = (payment['dueDate'] as Timestamp).toDate();
              final isCurrentMonth =
                  DateFormat('MMMM').format(DateTime.now()) == payment['month'];
              final isPastDue = !isPaid && dueDate.isBefore(DateTime.now());

              return Card(
                elevation: isCurrentMonth ? 4 : 2,
                margin: EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: isCurrentMonth
                      ? BorderSide(color: Color(0xFF1A2980), width: 2)
                      : BorderSide.none,
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            payment['month'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A2980),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isPaid
                                  ? Colors.green.withOpacity(0.1)
                                  : isPastDue
                                      ? Colors.red.withOpacity(0.1)
                                      : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isPaid
                                  ? 'PAID'
                                  : isPastDue
                                      ? 'OVERDUE'
                                      : 'UNPAID',
                              style: TextStyle(
                                color: isPaid
                                    ? Colors.green
                                    : isPastDue
                                        ? Colors.red
                                        : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Amount',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '₹${payment['amount']}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A2980),
                                ),
                              ),
                            ],
                          ),
                          if (!isPaid)
                            ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => _processPayment(payment['month']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF1A2980),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Pay Now',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (!isPaid && dueDate != null) ...[
                        SizedBox(height: 12),
                        Text(
                          'Due by ${DateFormat('MMM d').format(dueDate)}',
                          style: TextStyle(
                            color: isPastDue ? Colors.red : Colors.grey[600],
                            fontWeight:
                                isPastDue ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
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
