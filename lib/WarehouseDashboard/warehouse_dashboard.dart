// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:logistic_management_system/WarehouseDashboard/delivery.dart';
import 'package:logistic_management_system/WarehouseDashboard/printing.dart';
import 'package:logistic_management_system/WarehouseDashboard/production_monitoring.dart';
import 'package:logistic_management_system/WarehouseDashboard/quality_check.dart';
import 'package:logistic_management_system/WarehouseDashboard/tailoring.dart';
import 'package:logistic_management_system/WarehouseDashboard/inventory.dart';
import '../PartnerStore/login_page.dart';
import 'test_print.dart';
import 'rename.dart';

void main() => runApp(const WarehouseDashboardApp());

class WarehouseDashboardApp extends StatelessWidget {
  const WarehouseDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warehouse Dashboard',
      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Color(0xFFF5F5F5), // 👈 change this
        primaryColor: const Color(0xFFB92217),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WarehouseDashboard(),
        '/login_page': (context) => const LoginPage(),
        '/test_print': (context) => const TestPrint(),
        '/rename': (context) => const WarehouseRename(),
        '/delivery': (context) => const Delivery(),
        '/printing': (context) => const Printing(),
        '/quality_check': (context) => const QualityCheck(),
        '/tailoring': (context) => const Tailoring(),
        '/production_monitoring': (context) => const ProductionMonitoring(),
        '/inventory': (context) => const Inventory(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class WarehouseDashboard extends StatelessWidget {
  const WarehouseDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _sidebar(context),
          Expanded(
            child: Column(
              children: [
                _headerBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _dashboardGrid(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 **Sidebar**
  Widget _sidebar(BuildContext context) {
    return Container(
      width: 230,
      color: const Color(0xFFB92217),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _profileSection(),
          const SizedBox(height: 30),
          _sidebarItem(context, Icons.dashboard, "Dashboard", isSelected: true),
          _sidebarItem(context, Icons.monitor, "Monitoring",
              route: '/production_monitoring'),
          _sidebarItem(context, Icons.inventory, "Inventory",
              route: '/inventory'),
          const Spacer(),
          _logoutButton(context),
        ],
      ),
    );
  }

  /// 🔹 **Profile Section**
  Widget _profileSection() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage('assets/images/profile.png'),
            radius: 30,
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "User Name",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                "Warehouse Staff",
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🔹 **Sidebar Menu Items with Hover Effect & Active Highlight**
  Widget _sidebarItem(BuildContext context, IconData icon, String title,
      {String? route, bool isSelected = false}) {
    return MouseRegion(
      onEnter: (_) {},
      child: GestureDetector(
        onTap: route != null ? () => Navigator.pushNamed(context, route) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color:
                isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔹 **Logout Button**
  Widget _logoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(context, '/login_page');
      },
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
        child: Row(
          children: [
            Icon(Icons.logout, color: Colors.white, size: 22),
            SizedBox(width: 12),
            Text("Logout", style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  /// 🔹 **Header Bar with Search & Notifications**
  Widget _headerBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Dashboard",
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB92217)),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.black54, size: 24),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none,
                    color: Colors.black54, size: 24),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 🔹 **Dashboard Grid with Hover Effect**
  /// 🔹 **Dashboard Grid - Auto Fit to Screen without Scrolling**
  Widget _dashboardGrid(BuildContext context) {
    final items = [
      {
        'title': 'Test Print',
        'asset': 'assets/images/test_print.png',
        'route': '/test_print'
      },
      {
        'title': 'Rename',
        'asset': 'assets/images/rename.png',
        'route': '/rename'
      },
      {
        'title': 'Printing',
        'asset': 'assets/images/printing.png',
        'route': '/printing'
      },
      {
        'title': 'Tailoring',
        'asset': 'assets/images/tailoring.png',
        'route': '/tailoring'
      },
      {
        'title': 'Quality Check',
        'asset': 'assets/images/quality_check.png',
        'route': '/quality_check'
      },
      {
        'title': 'Delivery',
        'asset': 'assets/images/delivery.png',
        'route': '/delivery'
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate height based on available space and number of rows
        double availableHeight = constraints.maxHeight;
        int numberOfRows = 2; // You have 6 items (3 per row), so 2 rows
        double spacing = 12; // space between rows
        double cardHeight =
            (availableHeight - spacing * (numberOfRows - 1)) / numberOfRows;

        return GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: constraints.maxWidth /
              (3 * cardHeight), // adjust aspect ratio to fit perfectly
          children: items.map((item) {
            return SizedBox(
              height: cardHeight,
              child: _dashboardItem(
                context,
                item['title']!,
                item['asset']!,
                item['route'],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  /// 🔹 **Dashboard Cards with Hover Effect**
  /// 🔹 **Dashboard Cards with Custom Height**
  Widget _dashboardItem(
      BuildContext context, String title, String assetPath, String? route) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, route!),
        child: Card(
          color: const Color.fromARGB(
              255, 255, 255, 255), // 👈 Set your desired background color here
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(assetPath,
                  width: 70, height: 70, fit: BoxFit.contain),
              const SizedBox(height: 10),
              Text(
                title,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
