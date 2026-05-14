import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';

// Dummy imports (create these screens separately)
import 'dashboard_screen.dart';
import 'inventory_screen.dart';
import 'stock_transaction_screen.dart';
import 'reports_screen.dart';
import 'employees_screen.dart';
import 'suppliers_screen.dart';
import 'qr_scanner_screen.dart';
import 'dart:io';
import 'profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  final String? name;
  final String? email;
  final String? phone;
  final String? profileImageUrl;

  const HomeScreen({
    super.key,
    this.name,
    this.email,
    this.phone,
    this.profileImageUrl,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _bottomIndex = 0;
  int _topTabIndex = 0;

  String name = '';
  String email = '';
  String phone = '';
  String? profileImageUrl;

  bool _loadingData = true;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<Widget> _bottomScreens = const [
    SizedBox(), // Home
    QRScreen(),
    EmployeeScreen(),
    SupplierScreen(),
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _fadeController.forward();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    // ✅ Use passed data if available
    if (widget.name != null && widget.email != null) {
      setState(() {
        name = widget.name!;
        email = widget.email!;
        phone = widget.phone ?? '';
        profileImageUrl = widget.profileImageUrl;
        _loadingData = false;
      });
      return;
    }

    // Else fetch from Firebase
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data() as Map<String, dynamic>?;

      setState(() {
        name = data?['name'] ?? '';
        email = data?['email'] ?? '';
        phone = data?['phone'] ?? '';
        profileImageUrl = data?['profileImage']; // optional URL
        _loadingData = false;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Text("🏭 Warehouse",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(
                      name: name,
                      email: email,
                      phone: phone,
                      profileImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
                          ? NetworkImage(profileImageUrl!)
                          : const AssetImage("assets/profile.jpg") as ImageProvider,
                    ),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 20,
                backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
                    ? NetworkImage(profileImageUrl!)
                    : const AssetImage("assets/profile.jpg") as ImageProvider,
              ),
            ),
          ],
        ),
      ),
      body: _loadingData
          ? const Center(child: CircularProgressIndicator())
          : _bottomIndex == 0
          ? FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SafeArea(child: _buildHomeDashboard(context)),
        ),
      )
          : _bottomScreens[_bottomIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryYellow,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w400),
        onTap: (index) => setState(() => _bottomIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scanner'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Employees'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Suppliers'),
        ],
      ),
    );
  }

  Widget _buildHomeDashboard(BuildContext context) {
    final topTabs = ["Dashboard", "Inventory", "Transactions", "Reports"];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== Top Tabs =====
          FadeTransition(
            opacity: _fadeAnimation,
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: topTabs.length,
                itemBuilder: (context, index) {
                  final isSelected = _topTabIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _topTabIndex = index);
                      Future.microtask(() {
                        if (index == 1) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const InventoryScreen()),
                          );
                        } else if (index == 2) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const StockTransactionScreen()),
                          );
                        } else if (index == 3) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ReportsScreen()),
                          );
                        }
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryYellow : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryYellow
                              : Colors.grey.shade300,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: AppTheme.primaryYellow.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            )
                        ],
                      ),
                      child: Center(
                        child: Text(
                          topTabs[index],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppTheme.textDark,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ===== Mini Calendar Section =====
          FadeTransition(
            opacity: _fadeAnimation,
            child: SizedBox(
              height: 70,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: List.generate(7, (index) {
                  final day = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][index];
                  final status = [
                    "Pending",
                    "Loading",
                    "Loaded",
                    "Maintenance",
                    "Pending",
                    "Loading",
                    "Loaded"
                  ][index];
                  final color = {
                    "Pending": Colors.orange,
                    "Loading": Colors.blue,
                    "Loaded": Colors.green,
                    "Maintenance": Colors.red
                  }[status]!;

                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(status, style: TextStyle(fontSize: 12, color: color)),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ===== Chart Section =====
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              height: 150,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.redAccent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "3.4K This Month Cost",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.redAccent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 1),
                              FlSpot(1, 1.3),
                              FlSpot(2, 1.8),
                              FlSpot(3, 2.2),
                              FlSpot(4, 1.7),
                              FlSpot(5, 2.5),
                              FlSpot(6, 3.0),
                            ],
                            isCurved: true,
                            gradient: LinearGradient(
                              colors: [AppTheme.redAccent, Colors.redAccent],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            barWidth: 3,
                            dotData: FlDotData(show: false),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ===== Stat Cards =====
          FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildStatCards(),
            ),
          ),

          const SizedBox(height: 16),

          // ===== Dashboard Section =====
          FadeTransition(
            opacity: _fadeAnimation,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: DashboardScreen(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    final stats = [
      {"value": "2.8K", "label": "Total Package", "color": Colors.blue},
      {"value": "41.7K", "label": "Weekly Income", "color": Colors.indigo},
      {"value": "20.7K", "label": "Last Week", "color": Colors.deepPurple},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: stats.map((s) {
        final color = s["color"] as Color;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s["value"] as String,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s["label"] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
