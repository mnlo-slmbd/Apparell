import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';

class AdminExpenses extends StatelessWidget {
  const AdminExpenses({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        body: const AdminExpensesBody(),
      ),
    );
  }
}

class AdminExpensesBody extends StatefulWidget {
  const AdminExpensesBody({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdminExpensesBodyState createState() => _AdminExpensesBodyState();
}

class _AdminExpensesBodyState extends State<AdminExpensesBody> {
  bool _isDailyView = true;
  DateTime _fromDate = DateTime(2025, 1, 1);
  DateTime _selectedDate = DateTime(2025, 1, 1);

  final List<List<String>> _allDailyRows = [
    ['Main', '1000', '2000', '300', 'Office supplies'],
    ['Branch A', '1500', '2500', '400', 'Miscellaneous'],
    ['Branch B', '1200', '2200', '500', 'Travel expenses'],
    ['Branch C', '1800', '2800', '600', 'Repairs'],
  ];

  final List<List<String>> _allMonthlyRows = [
    ['Main', '30000', '20000', '5000', 'Various expenses'],
    ['Branch A', '45000', '35000', '7000', 'Events'],
    ['Branch B', '40000', '30000', '8000', 'Marketing'],
    ['Branch C', '60000', '45000', '10000', 'Maintenance'],
  ];

  List<List<String>> _filteredDailyRows = [];
  List<List<String>> _filteredMonthlyRows = [];

  final NumberFormat currencyFormat = NumberFormat('#,##0.00');

  @override
  void initState() {
    super.initState();
    _filterData();
  }

  void _filterData() {
    setState(() {
      if (_isDailyView) {
        _filteredDailyRows = List.from(_allDailyRows);
      } else {
        _filteredMonthlyRows = List.from(_allMonthlyRows);
      }
    });
  }

  Future<void> _selectDate(BuildContext context, bool isMonthly) async {
    if (isMonthly) {
      final DateTime? picked = await showMonthPicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2025, 1),
        lastDate: DateTime(2025, 12),
      );
      if (picked != null) {
        setState(() {
          _fromDate = DateTime(picked.year, picked.month, 1);
          _filterData();
        });
      }
    } else {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2025, 1, 1),
        lastDate: DateTime(2025, 12, 31),
      );
      if (picked != null) {
        setState(() {
          _selectedDate = picked;
          _filterData();
        });
      }
    }
  }

  double _calculateRowTotal(List<String> row) {
    return double.parse(row[1]) + double.parse(row[2]) + double.parse(row[3]);
  }

  double _calculateColumnTotal(int columnIndex, bool isDaily) {
    final rows = isDaily ? _filteredDailyRows : _filteredMonthlyRows;
    return rows.fold(
      0,
      (previousValue, element) =>
          previousValue + double.parse(element[columnIndex]),
    );
  }

  Future<void> _generatePDF(bool isDaily) async {
    final pdf = pw.Document();
    final logoImage = await rootBundle.load('assets/images/logo_1.png');
    final logo = pw.MemoryImage(logoImage.buffer.asUint8List());

    final rows = isDaily ? _filteredDailyRows : _filteredMonthlyRows;

    final materialsTotal = _calculateColumnTotal(1, isDaily);
    final payrollTotal = _calculateColumnTotal(2, isDaily);
    final othersTotal = _calculateColumnTotal(3, isDaily);
    final overallTotal = materialsTotal + payrollTotal + othersTotal;

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(logo, height: 60),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Zus Customs',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text('CBD II Triangulo, Naga City, Camarines Sur'),
                      pw.Text('zuscustoms2021@gmail.com'),
                      pw.Text('Contact: 123-456-7890'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                isDaily ? 'Daily Expenses Report' : 'Monthly Expenses Report',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                isDaily
                    ? 'Date: ${DateFormat('MMM.dd, yyyy').format(_selectedDate)}'
                    : 'Month: ${DateFormat('MMMM yyyy').format(_fromDate)}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 20),
              // ignore: deprecated_member_use
              pw.Table.fromTextArray(
                headers: [
                  'BRANCH',
                  'MATERIALS',
                  'PAYROLL',
                  'OTHERS',
                  'TOTAL EXPENSES',
                ],
                data: [
                  ...rows.map((row) => [
                        row[0],
                        currencyFormat.format(double.parse(row[1])),
                        currencyFormat.format(double.parse(row[2])),
                        currencyFormat.format(double.parse(row[3])),
                        currencyFormat.format(_calculateRowTotal(row)),
                      ]),
                  [
                    'Total',
                    currencyFormat.format(materialsTotal),
                    currencyFormat.format(payrollTotal),
                    currencyFormat.format(othersTotal),
                    currencyFormat.format(overallTotal),
                  ],
                ],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellStyle: const pw.TextStyle(fontSize: 12),
                cellAlignment: pw.Alignment.centerLeft,
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
    final rows = _isDailyView ? _filteredDailyRows : _filteredMonthlyRows;

    return Column(
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
                          : 'Month: ${DateFormat('MMMM yyyy').format(_fromDate)}',
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
                  });
                  _filterData();
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
                  });
                  _filterData();
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
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _generatePDF(_isDailyView),
                child: const Text('Generate Report'),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 1800),
              child: DataTable(
                columnSpacing: 50,
                headingRowColor: WidgetStateProperty.resolveWith(
                  (states) => const Color.fromARGB(255, 102, 166, 218),
                ),
                headingTextStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                columns: const [
                  DataColumn(label: Text('BRANCH')),
                  DataColumn(label: Text('MATERIALS')),
                  DataColumn(label: Text('PAYROLL')),
                  DataColumn(label: Text('OTHERS')),
                  DataColumn(label: Text('TOTAL EXPENSES')),
                ],
                rows: [
                  ...rows.map(
                    (row) => DataRow(
                      cells: [
                        DataCell(Text(row[0])),
                        DataCell(
                            Text(currencyFormat.format(double.parse(row[1])))),
                        DataCell(
                            Text(currencyFormat.format(double.parse(row[2])))),
                        DataCell(
                            Text(currencyFormat.format(double.parse(row[3])))),
                        DataCell(
                          Text(
                            currencyFormat.format(_calculateRowTotal(row)),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataRow(
                    cells: [
                      const DataCell(Text(
                        'Total',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                      DataCell(Text(
                        currencyFormat
                            .format(_calculateColumnTotal(1, _isDailyView)),
                      )),
                      DataCell(Text(
                        currencyFormat
                            .format(_calculateColumnTotal(2, _isDailyView)),
                      )),
                      DataCell(Text(
                        currencyFormat
                            .format(_calculateColumnTotal(3, _isDailyView)),
                      )),
                      DataCell(
                        Text(
                          currencyFormat.format(
                            _calculateColumnTotal(1, _isDailyView) +
                                _calculateColumnTotal(2, _isDailyView) +
                                _calculateColumnTotal(3, _isDailyView),
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 189, 226, 255),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Overall Total:',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '₱${currencyFormat.format(
                    _calculateColumnTotal(1, _isDailyView) +
                        _calculateColumnTotal(2, _isDailyView) +
                        _calculateColumnTotal(3, _isDailyView),
                  )}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Future<DateTime?> showMonthPicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) async {
  DateTime? selectedDate;
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      int selectedYear = initialDate.year;
      int selectedMonth = initialDate.month;
      return AlertDialog(
        title: const Text('Select Month'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<int>(
              value: selectedYear,
              onChanged: (int? newValue) {
                if (newValue != null) {
                  selectedYear = newValue;
                }
              },
              items: List.generate(
                lastDate.year - firstDate.year + 1,
                (index) => firstDate.year + index,
              ).map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
            ),
            DropdownButton<int>(
              value: selectedMonth,
              onChanged: (int? newValue) {
                if (newValue != null) {
                  selectedMonth = newValue;
                }
              },
              items: List.generate(12, (index) => index + 1)
                  .map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(DateFormat.MMMM().format(DateTime(0, value))),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: const Text('OK'),
            onPressed: () {
              selectedDate = DateTime(selectedYear, selectedMonth);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
  return selectedDate;
}
