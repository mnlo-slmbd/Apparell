// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:http/http.dart' as http;

class StoreSales extends StatelessWidget {
  final String storeName;

  const StoreSales({super.key, required this.storeName});

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
                'Sales Report',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
        body: StoreSalesBody(storeName: storeName), // <-- pass here
      ),
    );
  }
}

class StoreSalesBody extends StatefulWidget {
  final String storeName; // ✅ Add this line

  const StoreSalesBody(
      {super.key, required this.storeName}); // ✅ Add required storeName
  @override
  State<StoreSalesBody> createState() => _StoreSalesBodyState();
}

class _StoreSalesBodyState extends State<StoreSalesBody> {
  bool _isDailyView = true;
  DateTime _selectedDate = DateTime.now();
  DateTime _selectedMonth = DateTime.now();

  List<Map<String, dynamic>> _data = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });

    final String apiUrl = _isDailyView
        ? "http://localhost/Apparell_backend/fetch_daily_sales.php?date=${DateFormat('yyyy-MM-dd').format(_selectedDate)}&store=${Uri.encodeComponent(widget.storeName)}"
        : "http://localhost/Apparell_backend/fetch_monthly_sales.php?month=${DateFormat('yyyy-MM').format(_selectedMonth)}&store=${Uri.encodeComponent(widget.storeName)}";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          setState(() {
            _data = List<Map<String, dynamic>>.from(jsonResponse['data']);
            isLoading = false;
          });
        } else {
          throw Exception(jsonResponse['message']);
        }
      } else {
        throw Exception("Failed to fetch data.");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching data: $e")),
      );
    }
  }

  double _calculateOverallSales() {
    return _data.fold(
      0.0,
      (sum, row) => sum + (double.tryParse(row['total_sale'].toString()) ?? 0),
    );
  }

  String _formatCurrency(double amount) {
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '₱',
      decimalDigits: 2,
    );
    return currencyFormatter.format(amount);
  }

  List<Map<String, dynamic>> _groupDataByDateAndTeam() {
    Map<String, Map<String, List<Map<String, dynamic>>>> groupedData = {};

    for (var row in _data) {
      String date = row['date_order'] ?? 'N/A';
      String team = row['team_name'] ?? 'N/A';

      if (!groupedData.containsKey(date)) {
        groupedData[date] = {};
      }
      if (!groupedData[date]!.containsKey(team)) {
        groupedData[date]![team] = [];
      }
      groupedData[date]![team]!.add(row);
    }

    List<Map<String, dynamic>> organizedData = [];
    groupedData.forEach((date, teams) {
      teams.forEach((team, items) {
        organizedData.add({'date': date, 'team': team, 'items': items});
      });
    });

    return organizedData;
  }

  Future<void> _selectDate(BuildContext context, bool isMonthly) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isMonthly ? _selectedMonth : _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDatePickerMode:
          isMonthly ? DatePickerMode.year : DatePickerMode.day,
    );

    if (pickedDate != null) {
      setState(() {
        if (isMonthly) {
          _selectedMonth = pickedDate;
        } else {
          _selectedDate = pickedDate;
        }
      });
      _fetchData();
    }
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();

    // Load the store logo
    final imageLogo = await imageFromAssetBundle(
        'assets/images/logo_1.png'); // Ensure the correct path

    // Grouped data for better presentation
    List<Map<String, dynamic>> groupedData = _groupDataByDateAndTeam();
    double overallTotal = _calculateOverallSales(); // Compute total sales

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Store Details & Logo
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "CUSTOMER RECEIPT",
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
                    height: 50, // Adjust the height as needed
                    width: 100, // Adjust width for the logo
                    child: pw.Image(imageLogo),
                  ),
                ],
              ),
              pw.SizedBox(height: 10), // Spacing

              // Report Title
              pw.Text(
                _isDailyView ? 'Daily Sales Report' : 'Monthly Sales Report',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),

              // Table with removed Peso sign
              pw.Table.fromTextArray(
                headers: ['DATE', 'TEAM', 'ITEM', 'QTY', 'TOTAL'],
                data: groupedData.expand((group) {
                  String date = group['date'];
                  String team = group['team'];
                  List<Map<String, dynamic>> items = group['items'];

                  return items.map((item) {
                    return [
                      date,
                      team,
                      item['item'] ?? 'N/A',
                      item['qty'] ?? '0',
                      (double.tryParse(item['total_sale'].toString()) ?? 0)
                          .toStringAsFixed(2), // Removed Peso sign
                    ];
                  }).toList();
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
                    "Overall Total: ${overallTotal.toStringAsFixed(2)}", // Removed Peso sign
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
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
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _selectDate(context, !_isDailyView),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        _isDailyView
                            ? 'Date: ${DateFormat('MMM.dd, yyyy').format(_selectedDate)}'
                            : 'Month: ${DateFormat('MMMM yyyy').format(_selectedMonth)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isDailyView = true;
                      _fetchData();
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
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isDailyView = false;
                      _fetchData();
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
                  onPressed: _generatePDF,
                  child: const Text('Generate PDF'),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildOrganizedTable(),
          ),
          Container(
            color: Colors.blue[100],
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('OVERALL SALES:',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  _formatCurrency(_calculateOverallSales()),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizedTable() {
    List<Map<String, dynamic>> groupedData = _groupDataByDateAndTeam();

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: groupedData.map((group) {
          String team = group['team'];
          String date = group['date'];
          List<Map<String, dynamic>> items = group['items'];

          // Format date only in monthly view
          String formattedDate = _isDailyView
              ? ''
              : DateFormat('EEEE, MMM. dd, yyyy').format(DateTime.parse(date));

          // 💡 Compute subtotal per team
          double teamSubtotal = items.fold(
            0.0,
            (sum, item) =>
                sum + (double.tryParse(item['total_sale'].toString()) ?? 0),
          );

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (!_isDailyView) ...[
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  'Team: $team',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(2),
                  },
                  border: TableBorder.all(color: Colors.grey.shade300),
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(
                        color: Color(0xFFB3E5FC),
                      ),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: Text('ITEM')),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: Text('QTY')),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: Text('TOTAL')),
                        ),
                      ],
                    ),
                    ...items.map((item) {
                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(child: Text(item['item'] ?? 'N/A')),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(child: Text(item['qty'].toString())),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(_formatCurrency(
                                double.tryParse(
                                        item['total_sale'].toString()) ??
                                    0,
                              )),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Team Subtotal: ${_formatCurrency(teamSubtotal)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
