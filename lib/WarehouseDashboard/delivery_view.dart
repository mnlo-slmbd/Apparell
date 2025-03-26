import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Delivery extends StatefulWidget {
  const Delivery({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WarehouseRenameState createState() => _WarehouseRenameState();
}

class _WarehouseRenameState extends State<Delivery> {
  final List<Map<String, dynamic>> _orders = [
    {
      'teamName': 'Team Phoenix',
      'orderId': '0001',
      'orderType': 'Standard',
      'quantity': 50,
      'itemType': 'Shirts',
      'branch': 'Zus Custom Main',
      'dateOrder': DateTime(2024, 9, 27),
      'dueDate': DateTime(2024, 10, 17),
      'status': 'Completed',
      'statusUpdated': DateTime(2024, 10, 10, 22, 47),
      'details': 'Oct 10, 2024 10:47pm',
    },
    {
      'teamName': 'Tripplets',
      'orderId': '0002',
      'orderType': 'Rush',
      'quantity': 30,
      'itemType': 'Bags',
      'branch': 'Lotus Naga',
      'dateOrder': DateTime(2024, 9, 2),
      'dueDate': DateTime(2024, 9, 15),
      'status': 'On-going',
      'statusUpdated': DateTime(2024, 10, 9, 22, 0),
      'details': 'Oct 9, 2024 10:00pm',
    },
    {
      'teamName': 'Tripplets',
      'orderId': '0003',
      'orderType': 'Bulk',
      'quantity': 100,
      'itemType': 'Shoes',
      'branch': 'Chosen Few Iriga',
      'dateOrder': DateTime(2024, 9, 2),
      'dueDate': DateTime(2024, 9, 17),
      'status': 'Pending',
      'statusUpdated': DateTime(2024, 10, 9, 8, 0),
      'details': 'Oct 9, 2024 08:00am',
    },
  ];

  String _searchQuery = '';
  String _sortOption = 'All';

  void _logout() {
    Navigator.pushReplacementNamed(context, '/login_page');
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _orders
        .where((order) =>
            (_sortOption == 'All' || order['status'] == _sortOption) &&
            (order['teamName'].toLowerCase().contains(_searchQuery) ||
                order['orderId'].toLowerCase().contains(_searchQuery)))
        .toList();

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
              'Delivery',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
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
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.blue),
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
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.black),
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
                                  fontSize: 12,
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
                    color: const Color.fromARGB(255, 232, 231, 231),
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
                        _buildHeaderCell('Status', 2),
                        _buildHeaderCell('Last Update', 2),
                        _buildHeaderCell('Details', 1),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.black, thickness: 1),
                  ...filteredOrders.map((order) => _buildTableRow(order)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String title, int flex) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTableRow(Map<String, dynamic> order) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        children: [
          _buildCell(order['teamName'], 2),
          _buildCell(order['orderId'], 2),
          _buildCell(order['orderType'], 2),
          _buildCell(order['quantity'].toString(), 2),
          _buildCell(order['itemType'], 2),
          _buildCell(order['branch'], 2),
          _buildCell(DateFormat('MMM.dd, yyyy').format(order['dateOrder']), 2),
          _buildCell(DateFormat('MMM.dd, yyyy').format(order['dueDate']), 2),
          _buildStatusDropdown(order, 2),
          _buildCell(
              DateFormat('MMM.dd, hh:mm a').format(order['statusUpdated']), 2),
          _buildDetailsCell(order, 1),
        ],
      ),
    );
  }

  Widget _buildCell(String value, int flex) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        alignment: Alignment.centerLeft,
        child: Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(Map<String, dynamic> order, int flex) {
    return Expanded(
      flex: flex,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: constraints.maxWidth,
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: DropdownButton<String>(
              value: order['status'],
              underline: const SizedBox(),
              isExpanded: true,
              onChanged: (String? newValue) {
                setState(() {
                  order['status'] = newValue!;
                  order['statusUpdated'] = DateTime.now();
                });
              },
              items: ['Completed', 'On-going', 'Pending']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: value == 'Completed'
                          ? Colors.green
                          : value == 'On-going'
                              ? Colors.orange
                              : Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailsCell(Map<String, dynamic> order, int flex) {
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/delivery_view',
            arguments: order,
          );
        },
        child: const Text(
          'View',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}
