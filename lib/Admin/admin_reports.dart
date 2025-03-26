import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logistic_management_system/Admin/admin_finished_products.dart';
import 'package:logistic_management_system/Admin/monthly_sales_report.dart';
// Alias import for Inventory
import 'package:logistic_management_system/WarehouseDashboard/inventory.dart'
    // ignore: library_prefixes
    as WarehouseInventory;
import 'package:logistic_management_system/Admin/admin_expenses.dart'; // Import AdminExpenses
import 'package:logistic_management_system/Admin/admin_dashboard.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin Reports',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/admin-dashboard',
      routes: {
        '/inventory': (context) => const WarehouseInventory.Inventory(),
        '/admin_reports': (context) => const AdminReports(),
        '/monthly_sales_report': (context) => const MonthlySalesReport(),
        '/admin_finished_products': (context) => const FinishedProduct(),
        '/admin_expenses': (context) => const AdminExpenses(),
        '/admin-dashboard': (context) => const AdminDashboard(), // Add this
      },
    );
  }
}

class AdminReports extends StatefulWidget {
  const AdminReports({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdminReportsState createState() => _AdminReportsState();
}

class _AdminReportsState extends State<AdminReports> {
  bool _isHoveredSales = false;
  bool _isHoveredExpenses = false;
  bool _isHoveredInventory = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 185, 34, 23),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/admin-dashboard');
          },
          tooltip: 'Back to Reports',
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/admin-dashboard'),
              child: Image.asset('assets/images/logo_1.png', height: 60),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey.shade200],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildReportCard(
                    context,
                    'Sales',
                    'assets/images/sales_icon.png',
                    'View and track all sales transactions and reports.',
                    _isHoveredSales,
                    (hovered) => setState(() => _isHoveredSales = hovered),
                    onTap: () {
                      Navigator.pushNamed(context, '/monthly_sales_report');
                    },
                  ),
                  const SizedBox(width: 20),
                  _buildReportCard(
                    context,
                    'Expenses',
                    'assets/images/expenses_icon.png',
                    'Log and monitor business expenses.',
                    _isHoveredExpenses,
                    (hovered) => setState(() => _isHoveredExpenses = hovered),
                    onTap: () {
                      Navigator.pushNamed(context,
                          '/admin_expenses'); // Navigate to AdminExpenses
                    },
                  ),
                  const SizedBox(width: 20),
                  _buildReportCard(
                    context,
                    'Finished Products',
                    'assets/images/inventory_icon.png',
                    'Check and manage stock levels.',
                    _isHoveredInventory,
                    (hovered) => setState(() => _isHoveredInventory = hovered),
                    onTap: () {
                      Navigator.pushNamed(context, '/admin_finished_products');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context,
    String title,
    String imagePath,
    String description,
    bool isHovered,
    ValueChanged<bool> onHover, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        onEnter: (_) => onHover(true),
        onExit: (_) => onHover(false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 280,
          height: 350,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isHovered ? Colors.blue.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isHovered
                    ? Colors.blueAccent.withOpacity(0.6)
                    : Colors.grey.withOpacity(0.3),
                blurRadius: isHovered ? 15 : 10,
                spreadRadius: isHovered ? 5 : 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                height: 80,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isHovered ? Colors.blue.shade700 : Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
