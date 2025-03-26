// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:logistic_management_system/Admin/admin_reports.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FinishedProduct extends StatelessWidget {
  const FinishedProduct({super.key});

  @override
  Widget build(BuildContext context) {
    return const FinishedProductPage(); // Return the main page directly.
  }
}

class FinishedProductPage extends StatefulWidget {
  const FinishedProductPage({super.key});

  @override
  State<FinishedProductPage> createState() => _FinishedProductPageState();
}

class _FinishedProductPageState extends State<FinishedProductPage> {
  DateTime? fromDate;
  DateTime? toDate;

  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();

  List<Map<String, dynamic>> _data = [];

  Future<void> fetchData() async {
    final url = Uri.parse(
        'http://localhost/apparell/Apparell_backend/fetch_finished_products.php');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // ignore: avoid_print
        print(responseData);
        setState(() {
          _data = List<Map<String, dynamic>>.from(responseData);
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
  }

  int _calculateTotalQty() {
    return _data.fold<int>(
      0,
      (int sum, row) {
        // Safely parse each quantity to an integer
        final List<int> quantities = (row['quantities'] as String)
            .split(', ')
            .map<int>(
                (q) => int.tryParse(q) ?? 0) // Parse and handle invalid values
            .toList();

        // Calculate subtotal for the row
        final int subtotal = quantities.fold<int>(
          0,
          (int subtotal, int qty) => subtotal + qty,
        );

        return sum + subtotal; // Add to the total sum
      },
    );
  }

  void _selectDate(BuildContext context, bool isFrom) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        if (isFrom) {
          fromDate = pickedDate;
          fromDateController.text =
              DateFormat('MMM.dd.yyyy').format(pickedDate);
        } else {
          toDate = pickedDate;
          toDateController.text = DateFormat('MMM.dd.yyyy').format(pickedDate);
        }
      });
    }
  }

  Future<void> _generatePDF() async {
    if (fromDate == null || toDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both dates.')),
      );
      return;
    }

    final pdf = pw.Document();
    final filteredData = _data.where((row) {
      final date = DateFormat('MMM. dd, yyyy').parse(row['date_order']);
      return (date.isAfter(fromDate!) || date.isAtSameMomentAs(fromDate!)) &&
          (date.isBefore(toDate!) || date.isAtSameMomentAs(toDate!));
    }).toList();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Finished Product Report',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 20)),
              pw.SizedBox(height: 10),
              pw.Text('From: ${DateFormat('MMM dd, yyyy').format(fromDate!)}'),
              pw.Text('To: ${DateFormat('MMM dd, yyyy').format(toDate!)}'),
              pw.SizedBox(height: 20),
              // ignore: deprecated_member_use
              pw.Table.fromTextArray(
                headers: ['DATE', 'BRANCH', 'TEAM', 'ITEM', 'QTY'],
                data: filteredData.map((row) {
                  return [
                    row['date_order'],
                    row['store'],
                    row['team_name'],
                    row['description'],
                    row['qty']
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellStyle: const pw.TextStyle(fontSize: 12),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey300),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final totalQty = _calculateTotalQty();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 185, 34, 23),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/admin_reports');
          },
          tooltip: 'Back to Reports',
        ),
        title: Text(
          'Finished Product',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Date Picker and Generate Reports Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    child: _datePickerField(
                      label: 'From:',
                      controller: fromDateController,
                      onTap: () => _selectDate(context, true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 160,
                    child: _datePickerField(
                      label: 'To:',
                      controller: toDateController,
                      onTap: () => _selectDate(context, false),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Align(
                    alignment: Alignment
                        .center, // Adjust position (e.g., topLeft, center, etc.)
                    child: ElevatedButton(
                      onPressed: () async {
                        await _generatePDF(); // Call the function to generate and display the PDF report
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Container(
                        width: 150,
                        height: 30,
                        alignment: Alignment.center,
                        child: const Text(
                          'Generate Reports',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Table Header
            Container(
              padding: const EdgeInsets.all(8.0),
              color: const Color.fromARGB(255, 148, 207, 235),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                      flex: 2,
                      child: Text('DATE',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      flex: 2,
                      child: Text('BRANCH',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      flex: 2,
                      child: Text('TEAM',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      flex: 4,
                      child: Text('ITEM',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(
                      flex: 1,
                      child: Text('QTY',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: _data.length,
                itemBuilder: (context, index) {
                  final row = _data[index];
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: _tableCell(row['date_order'])),
                        Expanded(flex: 2, child: _tableCell(row['store'])),
                        Expanded(flex: 2, child: _tableCell(row['team_name'])),
                        Expanded(flex: 4, child: _tableCell(row['items'])),
                        Expanded(flex: 1, child: _tableCell(row['quantities'])),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Total Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              color: Colors.white,
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.end, // Align content to the right
                children: [
                  const Text(
                    'Total Quantity:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                      width: 8), // Add spacing between "TOTAL" and the value
                  Text(
                    '$totalQty',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: Colors.red, // Set color to red
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _datePickerField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 12)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade200,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.text.isNotEmpty ? controller.text : '--',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                ),
                const Icon(Icons.calendar_today, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _tableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }
}
