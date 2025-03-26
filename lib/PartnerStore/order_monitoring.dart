// ignore_for_file: use_build_context_synchronously, unnecessary_to_list_in_spreads

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Production Monitoring',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      home: const StoreMonitoring(
        storeName: '',
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class StoreMonitoring extends StatefulWidget {
  final String storeName;

  const StoreMonitoring({super.key, required this.storeName});
  @override
  State<StoreMonitoring> createState() => _ProductionMonitoringState();
}

class _ProductionMonitoringState extends State<StoreMonitoring> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> filteredOrders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  // Fetch orders from the backend
  Future<void> _fetchOrders() async {
    final String apiUrl =
        "http://localhost/apparell/Apparell_backend/get_production_stages_zus.php?store=${Uri.encodeComponent(widget.storeName)}";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          setState(() {
            orders = List<Map<String, dynamic>>.from(jsonResponse['data']);
            filteredOrders = orders;
            isLoading = false;
          });
        } else {
          throw Exception(jsonResponse['message']);
        }
      } else {
        throw Exception("Failed to fetch orders.");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching orders: $e")),
      );
    }
  }

  void _filterOrders(String query) {
    setState(() {
      filteredOrders = orders.where((order) {
        final team = (order['team_name'] ?? '').toLowerCase();
        return team.contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> updateMonitoringStatus(String orderId, String status) async {
    const String apiUrl =
        "http://localhost/apparell/Apparell_backend/update_production_status.php";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"order_id": orderId, "status": status}),
      );

      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Monitoring status updated: $status")),
        );
      } else {
        throw Exception(jsonResponse['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating monitoring status: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 185, 34, 23),
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
            Text(
              'Production Monitoring',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.white, // Set background color to white
        child: Column(
          children: [
            const SizedBox(height: 10),
            _FilterSection(
                onSearch: _filterOrders, searchController: _searchController),
            const SizedBox(height: 10),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: _OrderList(
                      orders: filteredOrders,
                      onUpdateStatus: updateMonitoringStatus,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final Function(String) onSearch;
  final TextEditingController searchController;

  const _FilterSection({
    required this.onSearch,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Ensures proper spacing
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/order_icon.png',
                    height: 25,
                    width: 25,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'ORDERS',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 200, // Adjust width for better appearance
                height: 35,
                child: TextField(
                  controller: searchController,
                  onChanged: onSearch,
                  style: GoogleFonts.poppins(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: GoogleFonts.poppins(fontSize: 12),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.search, size: 18),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  final Function(String, String) onUpdateStatus;

  const _OrderList({required this.orders, required this.onUpdateStatus});

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
          _HeaderCell('Delivery'),
          _HeaderCell('Status'),
        ],
      ),
    );
  }

  Widget _buildOrderRow(Map<String, dynamic> order) {
    final formattedDate = order['delivery_date'] != null
        ? DateFormat('MMM.dd, yyyy').format(
            DateTime.parse(order['delivery_date']),
          )
        : 'N/A';

    String status = order['delivery_status']?.toLowerCase() == 'completed'
        ? "Ready for Delivery"
        : order['status'] ?? 'N/A';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          _CenterCell(order['order_id'] ?? 'N/A'),
          _CenterCell(order['team_name'] ?? 'N/A'),
          _CenterCell(formattedDate),
          _CenterCell(
            order['category'] ?? 'N/A',
            color: (order['category']?.toLowerCase() == 'rush order')
                ? Colors.red
                : Colors.black,
          ),
          ...[
            'layout_status',
            'test_print_status',
            'rename_status',
            'printing_status',
            'tailoring_status',
            'qc_status',
            'delivery_status'
          ]
              .map<Widget>(
                  (step) => _IconCell(order[step]?.toLowerCase() ?? ''))
              .toList(),
          _StatusCell(status),
        ],
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
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold, // Keep header bold
          ),
        ),
      ),
    );
  }
}

class _CenterCell extends StatelessWidget {
  final String text;
  final Color color;

  const _CenterCell(this.text, {this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.normal, // Regular weight for table data
          ),
        ),
      ),
    );
  }
}

class _IconCell extends StatelessWidget {
  final String status;
  const _IconCell(this.status);

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    if (status == 'completed') {
      icon = Icons.check_circle;
      color = Colors.green;
    } else if (status == 'ongoing') {
      icon = Icons.access_time;
      color = Colors.orange;
    } else {
      icon = Icons.error;
      color = Colors.red;
    }

    return Expanded(
      child: Center(
        child: Icon(
          icon,
          color: color,
          size: 20,
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
            fontSize: 12,
            color: status.toLowerCase() == 'ready for delivery'
                ? Colors.green
                : status.toLowerCase() == 'completed'
                    ? Colors.green
                    : status.toLowerCase() == 'ongoing'
                        ? Colors.orange
                        : Colors.blue,
            fontWeight: FontWeight.normal, // Regular weight for statuses
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
