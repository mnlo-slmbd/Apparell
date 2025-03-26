// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Print',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Poppins',
      ),
      home: const TestPrint(),
    );
  }
}

class TestPrint extends StatefulWidget {
  const TestPrint({super.key});

  @override
  _TestPrintState createState() => _TestPrintState();
}

class _TestPrintState extends State<TestPrint> {
  List<Map<String, dynamic>> _orders = [];
  bool isLoading = true;
  String _searchQuery = '';
  String _sortOption = 'All';

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  // Fetch orders from the database
  Future<void> _fetchOrders() async {
    const String apiUrl =
        "http://localhost/Apparell_backend/get_testprint_orders.php";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          setState(() {
            _orders = List<Map<String, dynamic>>.from(jsonResponse['orders']);
            print(_orders); // Debugging: Check the data being fetched
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error fetching orders: $e")));
    }
  }

  // Update test print status in the database
  Future<void> _updateTestPrintStatus(String orderId, String status) async {
    if (orderId.isEmpty || status.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order ID or status is missing")),
      );
      return;
    }

    const String apiUrl =
        "http://localhost/Apparell_backend/update_testprint_status.php";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json
            .encode({'order_id': orderId, 'test_print_stage_status': status}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == 'success') {
          print("Response from API: $jsonResponse"); // Debugging line
          final updatedOrder = jsonResponse['updated_order'];

          // Update the order in the state
          setState(() {
            for (var order in _orders) {
              if (order['order_id'] == updatedOrder['order_id']) {
                order['test_print_stage_status'] =
                    updatedOrder['test_print_stage_status'];
                break;
              }
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Status updated successfully")),
          );
        } else {
          throw Exception(jsonResponse['message']);
        }
      } else {
        throw Exception(
            "Failed to update status. HTTP Status Code: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating status: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _orders
        .where((order) =>
            (_sortOption == 'All' || order['status'] == _sortOption) &&
            (order['team_name'].toLowerCase().contains(_searchQuery) ||
                order['order_id'].toLowerCase().contains(_searchQuery)))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 185, 34, 23),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/warehouse_dashboard');
          },
        ),
        title: Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Test Print',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildOrderTable(filteredOrders),
    );
  }

  Widget _buildOrderTable(List<Map<String, dynamic>> filteredOrders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Flexible(
                flex: 0,
                child: Container(
                  width: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 158, 158, 158)
                            .withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Colors.blue),
                      hintText: 'Search...',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 14.0,
                      ),
                    ),
                    style:
                        GoogleFonts.poppins(fontSize: 15, color: Colors.black),
                  ),
                ),
              ),
              const Spacer(),
              DropdownButton<String>(
                value: _sortOption,
                icon: const Icon(Icons.filter_list, color: Colors.blue),
                underline: const SizedBox(),
                onChanged: (value) {
                  setState(() {
                    _sortOption = value!;
                  });
                },
                items: ['All', 'Completed', 'On-going', 'Pending']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(
                            'Sort by: $status',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.black,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              Container(
                color: Colors.lightBlue[100], // Light blue header
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  children: [
                    _buildHeaderCell('Team Name', 2),
                    _buildHeaderCell('Order ID', 2),
                    _buildHeaderCell('Order Type', 2),
                    _buildHeaderCell('Quantity', 2),
                    _buildHeaderCell('Item Type', 2),
                    _buildHeaderCell('Branch', 2),
                    _buildHeaderCell('Date Order', 2),
                    _buildHeaderCell('Due Date', 2),
                    _buildHeaderCell('Status', 2),
                  ],
                ),
              ),
              const Divider(color: Colors.black, thickness: 1),
              ...filteredOrders.map((order) => _buildTableRow(order)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String title, int flex) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        alignment: Alignment.center,
        child: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildTableRow(Map<String, dynamic> order) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: const BoxDecoration(
        border: Border(
            bottom: BorderSide(
                color: Color.fromARGB(255, 158, 158, 158), width: 0.5)),
      ),
      child: Row(
        children: [
          _buildCell(order['team_name'] ?? 'N/A', 2),
          _buildStyledCell(
              order['order_id'] ?? 'N/A', 2, Colors.lightBlue, FontWeight.bold),
          _buildStyledCell(
              order['order_type'] ?? 'N/A',
              2,
              (order['order_type'] == 'Rush Order') ? Colors.red : Colors.black,
              FontWeight.normal),
          _buildCell(order['total_quantity']?.toString() ?? '0', 2),
          _buildCell(order['items'] ?? 'N/A', 2),
          _buildCell(order['store'] ?? 'N/A', 2),
          _buildCell(order['date_order'] ?? 'N/A', 2),
          _buildCell(order['delivery_date'] ?? 'N/A', 2),
          _buildStatusDropdown(
              order['test_print_stage_status'] ?? 'Pending', order),
        ],
      ),
    );
  }

  Widget _buildStyledCell(
      String value, int flex, Color textColor, FontWeight fontWeight,
      {bool isClickable = false}) {
    return Expanded(
      flex: flex,
      child: isClickable
          ? InkWell(
              onTap: () {
                print("Order ID clicked: $value");
                // You can navigate or show a dialog here
              },
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 150),
                tween: Tween(begin: 1.0, end: 1.05),
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      alignment: Alignment.center,
                      child: Text(
                        value,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: fontWeight,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              alignment: Alignment.center,
              child: Text(
                value,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: fontWeight,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
    );
  }

  Widget _buildCell(String value, int flex) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        alignment: Alignment.center,
        child: Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(String status, Map<String, dynamic> order) {
    final statusMapping = {
      "pending": "Pending",
      "completed": "Completed",
      "ongoing": "On-going",
    };

    final reverseStatusMapping = {
      "Pending": "pending",
      "Completed": "completed",
      "On-going": "ongoing",
    };

    final validStatuses = ["Pending", "Completed", "On-going"];
    String displayStatus = statusMapping[status] ?? "Pending";

    final statusColors = {
      "Pending": Colors.red,
      "Completed": Colors.green,
      "On-going": Colors.orange,
    };

    return Expanded(
      flex: 2,
      child: Container(
        alignment: Alignment.center,
        child: DropdownButton<String>(
          value: displayStatus,
          dropdownColor: Colors.white,
          underline: const SizedBox(),
          onChanged: (String? newDisplayStatus) async {
            if (newDisplayStatus != null) {
              String newValue =
                  reverseStatusMapping[newDisplayStatus] ?? "pending";

              // Update the status in the database and refresh the UI
              await _updateTestPrintStatus(order['order_id'] ?? '', newValue);
            }
          },
          items: validStatuses.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(
                  color: statusColors[value], // Assign color dynamically
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
