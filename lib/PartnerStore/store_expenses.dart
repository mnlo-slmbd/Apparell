// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

class StoreExpenses extends StatelessWidget {
  final String storeName;
  const StoreExpenses({super.key, required this.storeName});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
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
              const Spacer(),
              Text(
                'Expenses Report',
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
        body: ExpensesReportBody(storeName: storeName),
      ),
    );
  }
}

class ExpensesReportBody extends StatefulWidget {
  final String storeName;
  const ExpensesReportBody({super.key, required this.storeName});

  @override
  _ExpensesReportBodyState createState() => _ExpensesReportBodyState();
}

class _ExpensesReportBodyState extends State<ExpensesReportBody> {
  bool _isDailyView = true;
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _expenses = [];
  final NumberFormat currencyFormat = NumberFormat('#,##0.00');
  final String apiUrl =
      'http://localhost/apparell/Apparell_backend/expense_store.php';

  @override
  void initState() {
    super.initState();
    _fetchExpenses(); // Load all expenses on initialization
  }

  Future<void> _fetchExpenses() async {
    try {
      final response = await http.get(
        Uri.parse(
            '$apiUrl?view=all&store=${Uri.encodeComponent(widget.storeName)}'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _expenses =
              List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        throw Exception('Failed to load expenses');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching expenses: $e')),
      );
    }
  }

  Future<void> _addExpense(Map<String, dynamic> expense) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl?view=add'),
        body: json.encode(expense),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        _fetchExpenses();
      } else {
        throw Exception('Failed to add expense');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding expense: $e')),
      );
    }
  }

  void _showAddExpenseDialog() {
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    String selectedType = 'Materials';
    final DateTime currentDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Expense'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('Date: '),
                    Text(DateFormat('yyyy-MM-dd').format(currentDate)),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedType = newValue!;
                    });
                  },
                  items: ['Materials', 'Payroll', 'Others']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final Map<String, dynamic> newExpense = {
                  'doet': DateFormat('yyyy-MM-dd').format(currentDate),
                  'type': selectedType,
                  'description': descriptionController.text,
                  'amount': amountController.text,
                  'store_name': widget.storeName, // ✅ Include store
                };

                _addExpense(newExpense);
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();

    // Load the store logo as Uint8List
    final ByteData bytes = await rootBundle.load('assets/images/logo_1.png');
    final Uint8List imageBytes = bytes.buffer.asUint8List();
    final pw.ImageProvider imageLogo = pw.MemoryImage(imageBytes);

    // Compute Overall Total for the filtered expenses
    double overallTotal = _calculateOverallTotal();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Store Details and Logo
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "EXPENSES REPORT",
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        "CBD II Triangulo, Naga City, Camarines Sur",
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        "zuscustoms2021@gmail.com",
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(
                        "0998 226 1132 | 0945 533 1129",
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  pw.SizedBox(
                    height: 50,
                    width: 100,
                    child: pw.Image(imageLogo),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),

              // Report Title with Date
              pw.Text(
                _isDailyView
                    ? "Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate)}"
                    : "Month: ${DateFormat('MMM yyyy').format(_selectedDate)}",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),

              // Table with expenses data (ONLY FILTERED EXPENSES)
              pw.Table.fromTextArray(
                headers: ['Date', 'Type', 'Description', 'Amount'],
                data: _filteredExpenses().map((row) {
                  return [
                    row['doet'],
                    row['type'],
                    row['description'] ?? 'N/A',
                    (double.tryParse(row['amount'].toString()) ?? 0)
                        .toStringAsFixed(2),
                  ];
                }).toList(),
              ),

              pw.SizedBox(height: 20),

              // Overall Total Section
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                  ),
                  child: pw.Text(
                    "Overall Total: ${overallTotal.toStringAsFixed(2)}",
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Print or save PDF
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  double _calculateOverallTotal() {
    return _filteredExpenses().fold(
      0.0,
      (sum, row) => sum + (double.tryParse(row['amount'] ?? '0') ?? 0.0),
    );
  }

  Map<String, double> _calculateSummary() {
    final filteredData = _filteredExpenses();
    final summary = {
      'Materials': 0.0,
      'Payroll': 0.0,
      'Others': 0.0,
    };

    for (var expense in filteredData) {
      if (expense['type'] != null && summary.containsKey(expense['type'])) {
        summary[expense['type']] =
            (summary[expense['type']] ?? 0.0) + double.parse(expense['amount']);
      }
    }

    return summary;
  }

  List<Map<String, dynamic>> _filteredExpenses() {
    return _expenses.where((expense) {
      final expenseDate = DateFormat('yyyy-MM-dd').parse(expense['doet']);
      if (_isDailyView) {
        // Match exact day for daily view
        return expenseDate.year == _selectedDate.year &&
            expenseDate.month == _selectedDate.month &&
            expenseDate.day == _selectedDate.day;
      } else {
        // Match the month and year for monthly view
        return expenseDate.year == _selectedDate.year &&
            expenseDate.month == _selectedDate.month;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate filtered expenses dynamically
    final filteredExpenses =
        _filteredExpenses(); // Updates table data based on the current view
    final summary = _calculateSummary(); // Updates summary dynamically

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Top Bar with date selection and view toggle
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _selectedDate =
                              pickedDate; // Update the selected date
                        });
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _isDailyView
                              ? 'Date: ${DateFormat('MMM.dd, yyyy').format(_selectedDate)}'
                              : 'Month: ${DateFormat('MMM yyyy').format(_selectedDate)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                // Daily view toggle
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isDailyView = true; // Switch to daily view
                    });
                  },
                  child: Text(
                    'Daily',
                    style: TextStyle(
                      color: _isDailyView
                          ? const Color.fromARGB(255, 185, 34, 23)
                          : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Monthly view toggle
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isDailyView = false; // Switch to monthly view
                    });
                  },
                  child: Text(
                    'Monthly',
                    style: TextStyle(
                      color: !_isDailyView
                          ? const Color.fromARGB(255, 185, 34, 23)
                          : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _generatePDF, // Generates PDF report
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 185, 34, 23),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Generate Report'),
                ),
                const SizedBox(width: 10),
                if (_isDailyView) // Hide "Add Expense" button in Monthly View
                  ElevatedButton(
                    onPressed: _showAddExpenseDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Add Expense'),
                  ),
              ],
            ),
          ),
          // Data table displaying filtered expenses
          Expanded(
            child: SingleChildScrollView(
              scrollDirection:
                  Axis.horizontal, // Allow horizontal scrolling if needed
              child: Container(
                width: MediaQuery.of(context)
                    .size
                    .width, // Full width of the screen
                decoration: const BoxDecoration(),
                padding:
                    const EdgeInsets.all(8.0), // Padding around the DataTable
                child: DataTable(
                  columnSpacing: 8,
                  headingRowColor: MaterialStateProperty.all(
                      Colors.blue.shade100), // Set color for column headers
                  columns: [
                    const DataColumn(
                      label: Text(
                        'Date of Transaction',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const DataColumn(
                      label: Text(
                        'Type',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const DataColumn(
                      label: Text(
                        'Description',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const DataColumn(
                      label: Text(
                        'Amount',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    if (_isDailyView) // Only show "Actions" column in Daily View
                      const DataColumn(
                        label: Text(
                          'Actions',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                  ],
                  rows: filteredExpenses.map((expense) {
                    return DataRow(
                      cells: [
                        DataCell(Text(expense['doet'])),
                        DataCell(Text(expense['type'])),
                        DataCell(Text(expense['description'])),
                        DataCell(Text(currencyFormat
                            .format(double.parse(expense['amount'])))),
                        if (_isDailyView) // Only show "Actions" column in Daily View
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () {/* Edit Expense */},
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {/* Delete Expense */},
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // Summary section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Summary:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                    'Materials: ${currencyFormat.format(summary['Materials'] ?? 0.0)}'),
                Text(
                    'Payroll: ${currencyFormat.format(summary['Payroll'] ?? 0.0)}'),
                Text(
                    'Others: ${currencyFormat.format(summary['Others'] ?? 0.0)}'),
                const Divider(),
                Text(
                  'Overall Total: ${currencyFormat.format(_calculateOverallTotal())}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
