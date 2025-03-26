import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:logistic_management_system/PartnerStore/login_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Order Monitoring',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      routes: {
        '/login_page': (context) => const LoginPage(),
      },
      home: const WarehouseMonitoring(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WarehouseMonitoring extends StatefulWidget {
  const WarehouseMonitoring({super.key});

  @override
  State<WarehouseMonitoring> createState() => _ProductionMonitoringState();
}

class _ProductionMonitoringState extends State<WarehouseMonitoring> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> orders = [
    {
      'id': '0001',
      'team': 'Team Phoenix',
      'date': DateTime(2024, 9, 30),
      'category': 'Regular',
      'status': 'Ready for Delivery',
      'steps': [true, true, true, true, true, true],
    },
    {
      'id': '0002',
      'team': 'Tripplets',
      'date': DateTime(2024, 9, 27),
      'category': 'Rush',
      'status': 'For Lay-Out',
      'steps': [false, false, false, false, false, false],
    },
    {
      'id': '0003',
      'team': 'Big Builders',
      'date': DateTime(2024, 10, 1),
      'category': 'Big Order',
      'status': 'Pending',
      'steps': [false, true, false, true, false, true],
    },
    {
      'id': '0004',
      'team': 'Philgeps Unit',
      'date': DateTime(2024, 10, 5),
      'category': 'Philgeps',
      'status': 'In Progress',
      'steps': [true, true, true, false, true, false],
    }
  ];
  List<Map<String, dynamic>> filteredOrders = [];

  @override
  void initState() {
    super.initState();
    filteredOrders = orders;
  }

  void _filterOrders(String query) {
    setState(() {
      filteredOrders = orders.where((order) {
        final team = order['team'].toLowerCase();
        return team.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    int allOrdersCount = orders.length;
    int regularCount =
        orders.where((order) => order['category'] == 'Regular').length;
    int rushCount = orders.where((order) => order['category'] == 'Rush').length;
    int bigOrdersCount =
        orders.where((order) => order['category'] == 'Big Order').length;
    int philgepsCount =
        orders.where((order) => order['category'] == 'Philgeps').length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 17, 0),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/images/logo_1.png',
              height: 60,
            ),
            const Spacer(),
            Text(
              'Order Monitoring',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/login_page');
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _FilterSection(
            onSearch: _filterOrders,
            searchController: _searchController,
            allOrdersCount: allOrdersCount,
            regularCount: regularCount,
            rushCount: rushCount,
            bigOrdersCount: bigOrdersCount,
            philgepsCount: philgepsCount,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _OrderList(orders: filteredOrders),
          ),
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final Function(String) onSearch;
  final TextEditingController searchController;
  final int allOrdersCount;
  final int regularCount;
  final int rushCount;
  final int bigOrdersCount;
  final int philgepsCount;

  const _FilterSection({
    required this.onSearch,
    required this.searchController,
    required this.allOrdersCount,
    required this.regularCount,
    required this.rushCount,
    required this.bigOrdersCount,
    required this.philgepsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 15, vertical: 10), // Adjusted padding
      child: Column(
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.center, // Ensures elements align in center
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/order_icon.png',
                      height: 25,
                      width: 25,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ORDERS',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 250, // Fixed width for search bar for consistency
                height: 38,
                child: TextField(
                  controller: searchController,
                  onChanged: onSearch,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search orders...',
                    hintStyle: GoogleFonts.poppins(fontSize: 12),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.search, size: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildFilterBadge('All Orders', allOrdersCount.toString()),
                _buildFilterBadge('Regular', regularCount.toString()),
                _buildFilterBadge('Rush', rushCount.toString()),
                _buildFilterBadge('Big Orders', bigOrdersCount.toString()),
                _buildFilterBadge('Philgeps', philgepsCount.toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBadge(String label, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style:
                GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(width: 6),
          Text(
            count,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<Map<String, dynamic>> orders;

  const _OrderList({required this.orders});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildHeaderRow(),
        const Divider(height: 1, color: Color.fromARGB(255, 106, 184, 249)),
        ...orders.map((order) => _buildOrderRow(order)),
      ],
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      color: const Color.fromARGB(255, 182, 213, 255),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: const Row(
        children: [
          _HeaderCell('Order ID'),
          _HeaderCell('Team Name'),
          _HeaderCell('Delivery Date'),
          _HeaderCell('Category'),
          _HeaderCell('Layout'),
          _HeaderCell('Test Print'),
          _HeaderCell('Rename'),
          _HeaderCell('Printing'),
          _HeaderCell('Tailoring'),
          _HeaderCell('QC'),
          _HeaderCell('Status'),
        ],
      ),
    );
  }

  Widget _buildOrderRow(Map<String, dynamic> order) {
    final formattedDate = DateFormat('MMM.dd, yyyy').format(order['date']);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          _CenterCell(order['id']),
          _CenterCell(order['team']),
          _CenterCell(formattedDate),
          _CategoryCell(order['category']), // Updated to _CategoryCell
          ...order['steps']
              .map<Widget>((String stepStatus) => _IconCell(stepStatus))
              .toList(),

          _StatusCell(order['status']),
        ],
      ),
    );
  }
}

class _CategoryCell extends StatelessWidget {
  final String text;
  const _CategoryCell(this.text);

  @override
  Widget build(BuildContext context) {
    bool isRushOrder = text.toLowerCase() == 'rush' ||
        text.toLowerCase() == 'rush order'; // Ensures both cases

    return Expanded(
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: isRushOrder
                ? Colors.red
                : Colors.black, // Only Rush Order in red
          ),
        ),
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  const _HeaderCell(this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }
}

class _CenterCell extends StatelessWidget {
  final String text;
  const _CenterCell(this.text);

  @override
  Widget build(BuildContext context) {
    bool isRushOrder = text.toLowerCase() == 'rush'; // Check if "Rush Order"

    return Expanded(
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: isRushOrder ? Colors.red : Colors.black, // Red for "Rush"
          ),
        ),
      ),
    );
  }
}

class _IconCell extends StatelessWidget {
  final String stepStatus; // 'done', 'pending', or 'not_started'

  const _IconCell(this.stepStatus);

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (stepStatus) {
      case 'done':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'pending':
        icon = Icons.hourglass_bottom;
        color = Colors.orange;
        break;
      case 'not_started':
      default:
        icon = Icons.cancel;
        color = Colors.red;
        break;
    }

    return Expanded(
      child: Center(
        child: Icon(
          icon,
          color: color,
          size: 24,
        ),
      ),
    );
  }
}

class _StatusCell extends StatelessWidget {
  final String status;
  const _StatusCell(this.status);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          status,
          style: GoogleFonts.poppins(
            color: Colors.blue,
            fontStyle: FontStyle.italic,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
