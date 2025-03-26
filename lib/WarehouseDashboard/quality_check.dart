// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class QualityCheck extends StatefulWidget {
  const QualityCheck({super.key});

  @override
  _QualityCheckState createState() => _QualityCheckState();
}

class _QualityCheckState extends State<QualityCheck> {
  List<Map<String, dynamic>> _orders = [];
  bool isLoading = true;
  String _searchQuery = '';
  String _sortOption = 'All';

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  // Fetch orders from the backend
  Future<void> _fetchOrders() async {
    const String apiUrl =
        "http://localhost/apparell/Apparell_backend/get_qualitycheck_orders.php";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          setState(() {
            _orders = List<Map<String, dynamic>>.from(jsonResponse['orders']);
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

  // Update quality check status in the backend
  Future<void> _updateQualityCheckStatus(String orderId, String status) async {
    const String apiUrl =
        "http://localhost/apparell/Apparell_backend/update_qualitycheck_status.php";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({'order_id': orderId, 'qc_status': status}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == 'success') {
          setState(() {
            for (var order in _orders) {
              if (order['order_id'] ==
                  jsonResponse['updated_order']['order_id']) {
                order['qc_status'] = jsonResponse['updated_order']['qc_status'];
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
        throw Exception("Failed to update status.");
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
            (_sortOption == 'All' ||
                order['qc_status'] == _sortOption.toLowerCase()) &&
            (order['team_name'].toLowerCase().contains(_searchQuery) ||
                order['order_id'].toLowerCase().contains(_searchQuery)))
        .toList();

    return Scaffold(
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
            'Quality Check',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildOrderTable(filteredOrders),
      ),
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
                        color: Colors.grey.withOpacity(0.3),
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
                        horizontal: 12.0,
                      ),
                    ),
                    style:
                        GoogleFonts.poppins(fontSize: 13, color: Colors.black),
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
                padding: const EdgeInsets.all(12.0),
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
                    _buildHeaderCell('QC Status', 2),
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
    final bool isSpecialOrder = ["Rush Order", "Big Order", "Philgeps Order"]
        .contains(order['order_type']);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        children: [
          _buildCell(order['team_name'] ?? 'N/A', 2),
          _buildStyledCell(
              order['order_id'] ?? 'N/A', 2, Colors.lightBlue, FontWeight.bold,
              isOrderId: true), // Light blue Order ID
          _buildStyledCell(
            order['order_type'] ?? 'N/A',
            2,
            isSpecialOrder
                ? Colors.red
                : Colors.black, // Red for special orders, black for regular
            FontWeight.normal,
          ),
          _buildCell(order['total_quantity']?.toString() ?? '0', 2),
          _buildCell(order['items'] ?? 'N/A', 2),
          _buildCell(order['store'] ?? 'N/A', 2),
          _buildCell(order['date_order'] ?? 'N/A', 2),
          _buildCell(order['delivery_date'] ?? 'N/A', 2),
          _buildStatusDropdown(order['qc_status'] ?? 'pending', order),
        ],
      ),
    );
  }

  Widget _buildStyledCell(
      String value, int flex, Color color, FontWeight fontWeight,
      {bool isOrderId = false}) {
    return Expanded(
      flex: flex,
      child: MouseRegion(
        cursor: isOrderId
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic, // Clickable cursor for Order ID
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          alignment: Alignment.center,
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: fontWeight,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
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
      "ongoing": "On-going",
      "completed": "Completed",
    };

    final colors = {
      "Pending": Colors.red,
      "On-going": Colors.orange,
      "Completed": Colors.green,
    };

    return Expanded(
      flex: 2,
      child: Container(
        alignment: Alignment.center,
        child: DropdownButton<String>(
          value: statusMapping[status] ?? "Pending", // Default to "Pending"
          dropdownColor: Colors.white,
          underline: const SizedBox(),
          onChanged: (String? newStatus) {
            if (newStatus != null) {
              String newValue = statusMapping.entries
                  .firstWhere((entry) => entry.value == newStatus,
                      orElse: () => const MapEntry("pending", "Pending"))
                  .key;
              setState(() {
                order['qc_status'] = newValue;
              });
              _updateQualityCheckStatus(order['order_id'], newValue);
            }
          },
          items: statusMapping.values.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: colors[value] ?? Colors.black,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
