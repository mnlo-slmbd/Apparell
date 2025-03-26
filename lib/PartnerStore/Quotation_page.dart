// ignore_for_file: file_names, library_private_types_in_public_api, avoid_print, use_build_context_synchronously, deprecated_member_use, unnecessary_to_list_in_spreads

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // For formatting currency
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart'; // For print functionality
// For JSON encoding
import 'package:http/http.dart' as http; // For HTTP requests

class QuotationPage extends StatefulWidget {
  final List<Map<String, dynamic>> orderDetails;
  final double totalSale;
  final String customerName;
  final String contactNumber;
  final String address;
  final String email;
  final String orderType;
  final double balance;
  final String orderId;
  final String store;
  final String teamName;
  final String deliveryDate;
  final String mop;
  final double downpayment;
  final String dateOrder;
  final bool isNewOrderChecked; // Add this
  final bool isAdditionalOrderChecked; // Add this

  const QuotationPage({
    super.key,
    required this.orderDetails,
    required this.totalSale,
    required this.customerName,
    required this.contactNumber,
    required this.address,
    required this.email,
    required this.orderType,
    required this.balance,
    required this.orderId,
    required this.store,
    required this.teamName,
    required this.deliveryDate,
    required this.mop,
    required this.downpayment,
    required this.dateOrder,
    required this.isNewOrderChecked, // Add this
    required this.isAdditionalOrderChecked, // Add this
  });

  @override
  _QuotationPageState createState() => _QuotationPageState();
}

class _QuotationPageState extends State<QuotationPage> {
  bool isNewOrderChecked = false;
  bool isAdditionalOrderChecked = false;

  String formatCurrency(double amount) {
    return NumberFormat.currency(locale: "en_PH", symbol: "Php").format(amount);
  }

  // Function to save data to the database
  Future<void> saveOrderToDatabase() async {
    const String apiUrl =
        'http://localhost/apparell/Apparell_backend/save_order.php';

    // Parse deliveryDate and reformat it
    final parsedDeliveryDate =
        DateFormat('MMMM dd, yyyy').parse(widget.deliveryDate);
    final formattedDeliveryDate =
        DateFormat('yyyy-MM-dd').format(parsedDeliveryDate);

    final payload = {
      "order_id": widget.orderId,
      "customer_name": widget.customerName,
      "contact_number": widget.contactNumber,
      "address": widget.address,
      "email": widget.email,
      "order_type": widget.orderType,
      "is_new_order": widget.isNewOrderChecked ? 1 : 0,
      "is_additional_order": widget.isAdditionalOrderChecked ? 1 : 0,
      "delivery_date": formattedDeliveryDate, // Send correctly formatted date
      "date_order": widget.dateOrder,
      "store": widget.store,
      "team_name": widget.teamName,
      "mop": widget.mop,
      "downpayment": widget.downpayment.toString(),
      "balance": widget.balance.toString(),
      "total_sale": widget.totalSale.toString(),
      "order_details": widget.orderDetails,
    };

    print("Payload: ${jsonEncode(payload)}"); // Debug JSON

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode(payload), // Ensure the JSON is encoded correctly
        headers: {"Content-Type": "application/json"}, // Set proper headers
      );

      if (response.statusCode == 200) {
        print("Response: ${response.body}"); // Debug Response
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order saved successfully!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save order: ${data['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}')),
        );
      }
    } catch (error) {
      print("Error: $error"); // Debug Errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving order: $error')),
      );
    }
  }

  void _generatePdfAndPrint() async {
    final pdf = pw.Document();

    // Load the logo image
    final logo = pw.MemoryImage(
      (await rootBundle.load('assets/images/logo_1.png')).buffer.asUint8List(),
    );

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Customer Receipt Heading with Logo on the right
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment
                    .spaceBetween, // Space out the text and logo
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('CUSTOMER RECEIPT',
                          style: pw.TextStyle(
                              fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.Text('CBD II Triangulo, Naga City, Camarines Sur'),
                      pw.Text('zuscustoms2021@gmail.com'),
                      pw.Text('0998 226 1132 | 0945 533 1129'),
                    ],
                  ),
                  pw.Image(logo, width: 120, height: 120), // Make logo bigger
                ],
              ),
              pw.SizedBox(height: 20),
              // Customer Information
              pw.Text('Customer Name: ${widget.customerName}'),
              pw.Text('Contact: ${widget.contactNumber}'),
              pw.Text('Address: ${widget.address}'),
              pw.Text('Email: ${widget.email}'),
              pw.Text('Order Type: ${widget.orderType}'),
              pw.Text(
                'Classification: ${widget.isNewOrderChecked ? "New Order" : widget.isAdditionalOrderChecked ? "Additional Order" : "None"}',
              ),
              pw.Text('Delivery Date: ${widget.deliveryDate}'),
              pw.Text('MOP: ${widget.mop}'),
              pw.Text('Downpayment: ${formatCurrency(widget.downpayment)}'),
              pw.Text('Balance: ${formatCurrency(widget.balance)}'),
              pw.SizedBox(height: 20),

              // Store Details with Logo next to it (aligned to the right)
              // Store Details without Logo
              // For ORDER DETAILS, move it to the upper right corner
              pw.Row(
                mainAxisAlignment:
                    pw.MainAxisAlignment.end, // Align to the right
                children: [
                  pw.Text(
                    'ORDER DETAILS',
                    style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.red),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Order Details
              pw.Text('', style: const pw.TextStyle(fontSize: 16)),
              pw.Table.fromTextArray(
                headers: ['Item', 'Description', 'Qty', 'Unit Price', 'Total'],
                data: widget.orderDetails
                    .map((order) => [
                          order['description'],
                          order['description'],
                          order['qty'].toString(),
                          formatCurrency(order['unitPrice']),
                          formatCurrency(order['total']),
                        ])
                    .toList(),
              ),
              pw.SizedBox(height: 20),

              // Total Sale
              pw.Text('TOTAL: ${formatCurrency(widget.totalSale)}'),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 185, 34, 23),
        elevation: 0, // Removes the shadow
        automaticallyImplyLeading: false, // Hides the default back button
        title: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Align items to space out
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(
                    context, '/sample_purchase'); // Navigate to the order page
              },
            ),
            Row(
              children: [
                const Text(
                  'Quotation Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                    width:
                        10), // Add spacing between the text and the home button
                IconButton(
                  icon:
                      const Icon(Icons.home, color: Colors.white), // Home icon
                  onPressed: () {
                    Navigator.pushNamed(
                        context, '/order_page'); // Redirect to /order_page
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header Section
              const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'CUSTOMER RECEIPT',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'CBD II Triangulo, Naga City, Camarines Sur',
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    'zuscustoms2021@gmail.com',
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    '0998 226 1132 | 0945 533 1129',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Order Type Selection
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildOrderTypeCheckBox("Regular Order", widget.orderType),
                  buildOrderTypeCheckBox("Rush Order", widget.orderType),
                  buildOrderTypeCheckBox("Big Order", widget.orderType),
                  buildOrderTypeCheckBox("PhilGeps Order", widget.orderType),
                ],
              ),
              const SizedBox(height: 20),

              // Date Order and Store Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                    child: buildInfoRow('Date Order:', widget.dateOrder,
                        underline: true),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2,
                    child:
                        buildInfoRow('Store:', widget.store, underline: true),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Customer and Order Information
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildSectionHeader('CUSTOMER\'S INFORMATION'),
                        buildInfoRow('Customer Name:', widget.customerName,
                            underline: true),
                        buildInfoRow('Contact:', widget.contactNumber,
                            underline: true),
                        buildInfoRow('Address:', widget.address,
                            underline: true),
                        buildInfoRow('Email Address:', widget.email,
                            underline: true),
                        const SizedBox(height: 10),
                        buildInfoRow('Team Name:', widget.teamName,
                            underline: true),
                        buildInfoRow('Delivery Date:', widget.deliveryDate,
                            underline: true),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildSectionHeader('ORDER INFORMATION'),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2,
                          child: buildInfoRow('Order ID:', widget.orderId,
                              underline: true),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Classification clicked!')),
                            );
                          },
                          child: buildSectionHeader('CLASSIFICATION'),
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: widget.isNewOrderChecked,
                              onChanged:
                                  null, // Disable checkbox in QuotationPage
                            ),
                            const Text('New Order'),
                          ],
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: widget.isAdditionalOrderChecked,
                              onChanged:
                                  null, // Disable checkbox in QuotationPage
                            ),
                            const Text('Additional Order'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Order Details Table
              buildSectionHeader('ORDER DETAILS'),
              const SizedBox(height: 10),
              Table(
                border: TableBorder.all(color: Colors.black54),
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(5),
                  2: FlexColumnWidth(2),
                  3: FlexColumnWidth(2),
                  4: FlexColumnWidth(2),
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(color: Colors.grey),
                    children: [
                      buildTableHeader('ITEM'),
                      buildTableHeader('DESCRIPTION'),
                      buildTableHeader('QTY'),
                      buildTableHeader('UNIT PRICE'),
                      buildTableHeader('TOTAL'),
                    ],
                  ),
                  ...widget.orderDetails.map((order) {
                    return TableRow(
                      children: [
                        buildTableCell(order['description'], bold: true),
                        buildTableCell(order['description']),
                        buildTableCell(order['qty'].toString()),
                        buildTableCell(formatCurrency(order['unitPrice'])),
                        buildTableCell(formatCurrency(order['total'])),
                      ],
                    );
                  }).toList(),
                ],
              ),
              const SizedBox(height: 20),

              // Summary Section
              Align(
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    buildSectionHeader('SUMMARY'),
                    const SizedBox(height: 10),
                    buildSummaryRow('TOTAL:', formatCurrency(widget.totalSale)),
                    buildSummaryRow('MOP:', widget.mop),
                    buildSummaryRow(
                        'Downpayment:', formatCurrency(widget.downpayment)),
                    buildSummaryRow('Balance:', formatCurrency(widget.balance),
                        isRed: true),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            onPressed: _generatePdfAndPrint,
                            child: const Text(
                              'Print',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              minimumSize: const Size(
                                  140, 40), // Increased the minimum width
                            ),
                            onPressed: () async {
                              await saveOrderToDatabase(); // Save order to the database
                            },
                            child: const FittedBox(
                              // Ensures the text fits within the button
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Confirm Order',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOrderTypeCheckBox(String label, String currentType) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        children: [
          Icon(
            currentType == label
                ? Icons.check_box
                : Icons.check_box_outline_blank,
            size: 18,
          ),
          const SizedBox(width: 5),
          Text(label),
        ],
      ),
    );
  }

  Widget buildInfoRow(String label, String value, {bool underline = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Container(
              decoration: underline
                  ? const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.black)),
                    )
                  : null,
              child: Text(value),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.red,
      ),
    );
  }

  Widget buildTableHeader(String label) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildTableCell(String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style:
            TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal),
      ),
    );
  }

  Widget buildSummaryRow(String label, String value, {bool isRed = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isRed ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
