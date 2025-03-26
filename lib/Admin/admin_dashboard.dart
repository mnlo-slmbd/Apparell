import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logistic_management_system/Admin/job_order_request.dart';
import 'package:logistic_management_system/Admin/user_management.dart';
import 'package:logistic_management_system/Admin/admin_reports.dart';
import 'package:logistic_management_system/Admin/product_list.dart';
import 'package:logistic_management_system/PartnerStore/login_page.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const AdminDashboardApp());
}

class AdminDashboardApp extends StatelessWidget {
  const AdminDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/user-management': (context) => const UserManagement(),
        '/job-order-request': (context) => const JobOrderRequest(),
        '/admin_reports': (context) => const AdminReports(),
        '/product-list': (context) => const ProductList(),
        '/login_page': (context) => const LoginPage(),
      },
      home: const AdminDashboard(),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String selectedMenu = 'Overview';

  double totalSales = 0;
  int totalOrders = 0;
  int productsSold = 0;
  int newCustomers = 0;
  int users = 0;

  List<Map<String, dynamic>> branches = [
    {'name': 'Lotus Iriga', 'totalSales': 0},
    {'name': 'Zus Customs Main', 'totalSales': 0},
    {'name': 'Chosen Few Goa', 'totalSales': 0},
    {'name': 'Chosen Few Naga', 'totalSales': 0},
    {'name': 'Chosen Few Sipocot', 'totalSales': 0},
    {'name': 'Lotus Naga', 'totalSales': 0},
    {'name': 'Parklane', 'totalSales': .0},
    {'name': 'Nabua Dry Goods', 'totalSales': 0},
    {'name': 'Chosen Few Legazpi', 'totalSales': .0},
  ];

  void refreshBranchData() {
    setState(() {
      branches.sort((a, b) => b['totalSales'].compareTo(a['totalSales']));
    });
  }

  String formatNumber(double number) {
    return NumberFormat('#,##0.00').format(number);
  }

  @override
  void initState() {
    super.initState();
    refreshBranchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 250,
            color: const Color.fromARGB(255, 185, 34, 23),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 30, color: Colors.red),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Admin',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white54),
                // Menu Items
                _sidebarItem('Users', Icons.people, '/user-management'),
                _sidebarItem('Task Assign', Icons.assignment, '/task_assign'),
                _sidebarItem('Reports', Icons.analytics, '/admin_reports'),
                _sidebarItem(
                    'Products', Icons.shopping_basket, '/product-list'),
                const Spacer(),
                // Logout
                _sidebarItem('Logout', Icons.exit_to_app, '/login_page'),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: 1.0,
                      child: Text(
                        "Overview",
                        style: GoogleFonts.poppins(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Sales Summary
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SalesCard(
                            '₱${formatNumber(totalSales)}',
                            'Total Sales',
                            const LinearGradient(
                              colors: [Colors.greenAccent, Colors.lightGreen],
                            ),
                            Icons.attach_money),
                        SalesCard(
                            '$totalOrders',
                            'Total Orders',
                            const LinearGradient(
                              colors: [
                                Colors.lightBlueAccent,
                                Colors.lightBlue
                              ],
                            ),
                            Icons.shopping_cart_outlined),
                        SalesCard(
                            '$productsSold',
                            'Products Sold',
                            const LinearGradient(
                              colors: [Colors.orangeAccent, Color(0xFFFFCC80)],
                            ),
                            Icons.inventory_2),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SalesCard(
                            '$newCustomers',
                            'New Customers',
                            const LinearGradient(
                              colors: [Colors.purpleAccent, Color(0xFFB39DDB)],
                            ),
                            Icons.person_add_alt_1),
                        SalesCard(
                            '$users',
                            'Users',
                            const LinearGradient(
                              colors: [Colors.tealAccent, Color(0xFF80CBC4)],
                            ),
                            Icons.group_outlined),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Branch List
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Store Performance",
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh,
                                    color: Colors.black87),
                                onPressed: refreshBranchData,
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Expanded(
                            child: ListView.builder(
                              itemCount: branches.length,
                              itemBuilder: (context, index) {
                                final branch = branches[index];
                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  decoration: BoxDecoration(
                                    color: index % 2 == 0
                                        ? Colors.grey.shade200
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8.0),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    leading: Container(
                                      width: 40,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        '${index + 1}',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      branch['name'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                      ),
                                    ),
                                    trailing: Text(
                                      '₱${formatNumber(branch['totalSales'])}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color:
                                            const Color.fromARGB(255, 0, 0, 0),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Sidebar Item Widget
  Widget _sidebarItem(String title, IconData icon, String routeName) {
    return MouseRegion(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedMenu = title;
          });
          if (routeName.isNotEmpty) {
            Navigator.of(context).pushNamed(routeName);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          color: selectedMenu == title
              ? Colors.white.withOpacity(0.2)
              : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 12),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: selectedMenu == title ? 1.0 : 0.7,
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white,
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

// Sales Card Widget
class SalesCard extends StatelessWidget {
  final String value;
  final String label;
  final LinearGradient gradient;
  final IconData icon;

  const SalesCard(this.value, this.label, this.gradient, this.icon,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12, // Subtle dropdown shadow
              blurRadius: 4,
              offset: Offset(1, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            AnimatedScale(
              scale: 1.0,
              duration: const Duration(milliseconds: 300),
              child: Icon(icon, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
