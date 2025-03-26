import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class JobOrderRequest extends StatefulWidget {
  const JobOrderRequest({super.key});

  @override
  State<JobOrderRequest> createState() => _JobOrderRequestState();
}

class _JobOrderRequestState extends State<JobOrderRequest> {
  final Map<String, String?> _assignedTo = {
    "0001": null,
  };

  final Map<String, String?> _details = {
    "0001": null,
  };

  final List<Map<String, String>> _orders = [
    {
      "orderId": "0001",
      "teamName": "Team Phoenix",
      "deliveryDate": "June 30, 2024",
      "branch": "Zus Main",
      "orderType": "Rush",
      "quantity": "100",
      "itemType": "T-Shirts",
    },
  ];
  void _navigateToDetails(BuildContext context, String? orderId) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsPage(orderId: orderId, data: null,),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/admin-dashboard');
              },
              child: Image.asset(
                'assets/images/logo_1.png',
                height: 50,
              ),
            ),
            Text(
              'Task Assign',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusTab("All Orders", _orders.length, Colors.blue),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 180,
                  height: 36,
                  child: TextField(
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      hintText: 'Search a task...',
                      hintStyle: GoogleFonts.poppins(fontSize: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.search, size: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: screenWidth,
                    ),
                    child: DataTable(
                      columnSpacing: screenWidth < 600 ? 8 : 32,
                      // ignore: deprecated_member_use
                      dataRowHeight: 60,
                      columns: _buildResponsiveColumns(),
                      rows: _orders
                          .map((order) => _buildDataRow(
                                context,
                                orderId: order["orderId"]!,
                                teamName: order["teamName"]!,
                                deliveryDate: order["deliveryDate"]!,
                                branch: order["branch"]!,
                                orderType: order["orderType"]!,
                                quantity: order["quantity"]!,
                                itemType: order["itemType"]!,
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTab(String label, int count, Color color) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          radius: 12,
          backgroundColor: color,
          child: Text(
            "$count",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
          ),
        ),
      ],
    );
  }

  List<DataColumn> _buildResponsiveColumns() {
    return [
      _buildDataColumn("Order ID"),
      _buildDataColumn("Team Name"),
      _buildDataColumn("Delivery Date"),
      _buildDataColumn("Branch"),
      _buildDataColumn("Order Type"),
      _buildDataColumn("Quantity"),
      _buildDataColumn("Item Type"),
      _buildDataColumn("Assign to"),
      _buildDataColumn("Details"),
    ];
  }

  DataColumn _buildDataColumn(String label) {
    return DataColumn(
      label: Text(
        label,
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      ),
    );
  }

  DataRow _buildDataRow(
    BuildContext context, {
    required String orderId,
    required String teamName,
    required String deliveryDate,
    required String branch,
    required String orderType,
    required String quantity,
    required String itemType,
  }) {
    return DataRow(
      cells: [
        DataCell(
          GestureDetector(
            onTap: () => _navigateToDetails(context, orderId),
            child: Text(
              orderId,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        DataCell(Text(teamName, style: GoogleFonts.poppins())),
        DataCell(Text(deliveryDate, style: GoogleFonts.poppins())),
        DataCell(Text(branch, style: GoogleFonts.poppins())),
        DataCell(
          Text(
            orderType,
            style: GoogleFonts.poppins(
              color: orderType == "Rush" || orderType == "Big Order"
                  ? Colors.red
                  : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        DataCell(Text(quantity, style: GoogleFonts.poppins())),
        DataCell(Text(itemType, style: GoogleFonts.poppins())),
        DataCell(
          DropdownButton<String?>(
            value: _assignedTo[orderId],
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: Colors.white,
            icon: Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: _assignedTo[orderId] == null ? Colors.red : Colors.green,
            ),
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black),
            items: const [
              DropdownMenuItem(value: null, child: Text("Select")),
              DropdownMenuItem(value: "Sherwin", child: Text("Sherwin")),
              DropdownMenuItem(value: "Jron", child: Text("Jron")),
              DropdownMenuItem(
                value: "Skip to Warehouse",
                child: Text("Skip to Warehouse"),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _assignedTo[orderId] = value;
                _details[orderId] = value != null
                    ? DateFormat('MMM dd, yyyy h:mm a').format(DateTime.now())
                    : null;
              });
            },
          ),
        ),
        DataCell(Text(
          _details[orderId] ?? '',
          style: GoogleFonts.poppins(fontSize: 12),
        )),
      ],
    );
  }
}

class OrderDetailsPage extends StatefulWidget {
  final String? orderId;

  const OrderDetailsPage({
    super.key,
    this.orderId, required data,
  });

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  Map<String, dynamic>? details;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails(widget.orderId);
  }

  Future<void> _fetchOrderDetails(String? orderId) async {
    const String apiUrl = "http://localhost/Apparell_backend/get_order.php";
    try {
      final String url = orderId != null
          ? "$apiUrl?orderId=${orderId.replaceFirst(RegExp(r'^0+'), '')}"
          : "$apiUrl?latest=true";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success']) {
          setState(() {
            details = responseData['data'];
          });
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(responseData['message'] ?? 'Failed to fetch details')),
          );
        }
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching order details: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (details == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 185, 34, 23),
          title: Text('Order Details - ${widget.orderId ?? 'Latest'}',
              style: GoogleFonts.poppins()),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final customer = details!['customer'];
    final order = details!['order'];
    final items = details!['items'] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 185, 34, 23),
        title: Text('Order Details - ${widget.orderId ?? 'Latest'}',
            style: GoogleFonts.poppins()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Center(
                child: Column(
                  children: [
                    Text(
                      'CUSTOMER RECEIPT',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'CBD II Triangulo, Naga City, Camarines Sur\nzuscustoms2021@gmail.com\n0998 226 1132 | 0945 533 1129',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Divider(thickness: 1.5),
              const SizedBox(height: 16),

              // Classification Section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: order['order_type'] == 'Regular Order',
                        onChanged: null,
                      ),
                      const Text('Regular Order'),
                      Checkbox(
                        value: order['order_type'] == 'Rush Order',
                        onChanged: null,
                      ),
                      const Text('Rush Order'),
                      Checkbox(
                        value: order['order_type'] == 'Big Order',
                        onChanged: null,
                      ),
                      const Text('Big Order'),
                      Checkbox(
                        value: order['order_type'] == 'Philgeps Order',
                        onChanged: null,
                      ),
                      const Text('Philgeps Order'),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Checkbox(
                    value: true, // Always checked for New Order
                    onChanged: null,
                  ),
                  const Text('New Order'),
                  Checkbox(
                    value: order['classification'] == 'Additional',
                    onChanged: null,
                  ),
                  const Text('Additional'),
                ],
              ),

              // Customer Information Section
              const SizedBox(height: 16),
              Text(
                "CUSTOMER'S INFORMATION",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              _buildKeyValue('Customer Name:', customer['name']),
              _buildKeyValue('Contact:', customer['contact_number']),
              _buildKeyValue('Address:', customer['address']),
              _buildKeyValue('Email Address:', customer['email']),
              const SizedBox(height: 8), // Add space below Email Address
              _buildKeyValue('Team Name:', order['team_name']),
              _buildKeyValue('Order Type:', order['order_type'] ?? 'N/A'),
              _buildKeyValue('Delivery Date:', order['due_date']),
              const Divider(thickness: 1.5),

              // Order Details Section
              Text(
                'ORDER DETAILS',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Table(
                border: TableBorder.all(),
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(3),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(1),
                  4: FlexColumnWidth(1),
                },
                children: [
                  _buildTableHeaderRow(),
                  // ignore: unnecessary_to_list_in_spreads
                  ...items.map((item) => _buildTableRow(item)).toList(),
                ],
              ),
              const SizedBox(height: 16),

              // Summary Section
              Align(
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildSummaryRow('TOTAL:', order['overall_total'] ?? '0'),
                    _buildSummaryRow('MOP:', order['payment_method'] ?? 'N/A'),
                    _buildSummaryRow(
                        'Downpayment:', order['down_payment'] ?? '0'),
                    _buildSummaryRow('Balance:', order['balance'] ?? '0'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyValue(String key, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              key,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? '',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableHeaderRow() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade300),
      children: [
        _buildTableHeaderCell('ITEM'),
        _buildTableHeaderCell('DESCRIPTION'),
        _buildTableHeaderCell('QTY'),
        _buildTableHeaderCell('UNIT PRICE'),
        _buildTableHeaderCell('TOTAL'),
      ],
    );
  }

  Widget _buildTableHeaderCell(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  TableRow _buildTableRow(Map<String, dynamic> item) {
    return TableRow(
      children: [
        _buildTableCell(item['item']),
        _buildTableCell(item['description']),
        _buildTableCell(item['quantity'].toString()),
        _buildTableCell(item['unit_price'].toString()),
        _buildTableCell(item['total'].toString()),
      ],
    );
  }

  Widget _buildTableCell(String value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(fontSize: 12),
      ),
    );
  }

  Widget _buildSummaryRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(
            value ?? '',
            style: GoogleFonts.poppins(),
          ),
        ],
      ),
    );
  }
}
