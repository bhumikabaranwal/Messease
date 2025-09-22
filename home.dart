import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/menu_service.dart';
import 'login.dart';
import 'menu.dart';
import 'admin_menu_editor.dart';
import 'payment_screen.dart';
import 'admin_panel.dart';
import 'student_complaint.dart';
import 'admin_complaints.dart';
import 'student_attendance.dart';
import 'admin_attendance_dashboard.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isAdmin = false;
  String userName = "User";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          userName = userData['name'] ?? user.email?.split('@')[0] ?? "User";
          isAdmin = userData['role'] == 'admin';
        });
      }
    }
  }

  void _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LogIn()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Color(0xFF1A2980)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'MessEase',
          style: TextStyle(
            color: Color(0xFF1A2980),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFF26D0CE),
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : "U",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            _buildWelcomeCard(),

            // Quick Actions Title
            Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2980),
                ),
              ),
            ),

            // Grid Menu
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildActionCard(
                    "Today's Menu",
                    Icons.restaurant_menu,
                    Colors.blueAccent,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MenuPage()),
                    ),
                  ),
                  if (!isAdmin)
                    _buildActionCard(
                      'Make Payment',
                      Icons.payment,
                      Colors.green,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PaymentScreen()),
                        );
                      },
                    ),
                  if (!isAdmin) ...[
                    _buildActionCard(
                      'Mark Attendance',
                      Icons.how_to_reg,
                      Colors.purple,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudentAttendance(),
                          ),
                        );
                      },
                    ),
                    _buildActionCard(
                      'Register Complaint',
                      Icons.report_problem,
                      Colors.orange,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudentComplaint(),
                          ),
                        );
                      },
                    ),
                  ],
                
                  if (isAdmin) ...[
                    _buildActionCard(
                      'Initialize Menu',
                      Icons.restaurant,
                      Colors.teal,
                      () => _showInitializeMenuDialog(),
                    ),
                    _buildActionCard(
                      'Edit Menu',
                      Icons.edit_note,
                      Colors.indigo,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AdminMenuEditor()),
                        );
                      },
                    ),
                    _buildActionCard(
                      'View Complaints',
                      Icons.report_problem,
                      Colors.orange,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminComplaints(),
                          ),
                        );
                      },
                    ),
                    _buildActionCard(
                      'Attendance Dashboard',
                      Icons.dashboard,
                      Colors.teal,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminAttendanceDashboard(),
                          ),
                        );
                      },
                    ),
                    _buildActionCard(
                      'Admin Panel',
                      Icons.admin_panel_settings,
                      Colors.redAccent,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AdminPanel()),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A2980),
            Color(0xFF26D0CE),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    userName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.logout, color: Colors.white70),
                onPressed: _signOut,
                tooltip: 'Sign Out',
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.notifications_none, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Check out today\'s special menu!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1A2980),
                    Color(0xFF26D0CE),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Icon(Icons.person, color: Colors.white, size: 36),
                  ),
                  SizedBox(height: 12),
                  Text(
                    userName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _auth.currentUser?.email ?? "",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.fastfood, 'View Menu', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MenuPage()),
              );
            }),
            if (!isAdmin)
              _buildDrawerItem(Icons.payment, 'Make Payment', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaymentScreen()),
                );
              }),
            if (!isAdmin) ...[
              _buildDrawerItem(Icons.how_to_reg, 'Mark Attendance', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StudentAttendance()),
                );
              }),
              _buildDrawerItem(Icons.report_problem, 'Register Complaint', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StudentComplaint()),
                );
              }),
            ],
            if (isAdmin) ...[
              Divider(height: 1, color: Colors.grey[300]),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  'ADMIN',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              _buildDrawerItem(Icons.edit_note, 'Edit Menu', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminMenuEditor()),
                );
              }),
              _buildDrawerItem(Icons.report_problem, 'View Complaints', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminComplaints()),
                );
              }),
              _buildDrawerItem(Icons.dashboard, 'Attendance Dashboard', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AdminAttendanceDashboard()),
                );
              }),
              _buildDrawerItem(Icons.admin_panel_settings, 'Admin Controls',
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminPanel()),
                );
              }),
            ],
            Divider(height: 1, color: Colors.grey[300]),
            _buildDrawerItem(Icons.logout, 'Logout', _signOut),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF1A2980)),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showInitializeMenuDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Initialize Menu'),
          content: Text(
              'This will set up the default weekly menu. Are you sure you want to proceed?'),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Color(0xFF1A2980))),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Yes', style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(
                backgroundColor: Color(0xFF1A2980),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Initializing menu data...'),
                    duration: Duration(seconds: 2),
                  ),
                );
                await MenuService.initializeMenuData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Menu initialized successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
