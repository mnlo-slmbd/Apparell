import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// Main entry point of the application
class MonthlySalesReport extends StatelessWidget {
  const MonthlySalesReport({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MonthlySalesReportPage(),
    );
  }
}

// Stateful widget to manage the Monthly Sales Report page
class MonthlySalesReportPage extends StatefulWidget {
  const MonthlySalesReportPage({super.key});

  @override
  State<MonthlySalesReportPage> createState() => _MonthlySalesReportPageState();
}

// State class for the MonthlySalesReportPage
class _MonthlySalesReportPageState extends State<MonthlySalesReportPage> {
  DateTime? fromDate; // Variable to store selected "From" date
  DateTime? toDate; // Variable to store selected "To" date

  // Sales data to be displayed in the table
  final List<Map<String, String>> _salesData = [
    {
      'date': 'Sept.01, 2024',
      'zusMain': '15,000',
      'lotusNaga': '17,000',
      'chosenNaga': '18,000',
      'parklane': '30,000',
      'lotusIriga': '12,000',
      'chosenIriga': '18,000',
      'nabuaDryGoods': '5,000',
      'daet': '16,000',
      'legazpi': '10,100',
      'goa': '15,000',
      'sipocot': '14,000',
    },
    {
      'date': 'Sept.02, 2024',
      'zusMain': '28,000',
      'lotusNaga': '11,000',
      'chosenNaga': '18,000',
      'parklane': '35,000',
      'lotusIriga': '15,000',
      'chosenIriga': '20,000',
      'nabuaDryGoods': '18,000',
      'daet': '20,000',
      'legazpi': '11,800',
      'goa': '15,000',
      'sipocot': '19,000',
    },
    {
      'date': 'Sept.03, 2024',
      'zusMain': '50,000',
      'lotusNaga': '15,000',
      'chosenNaga': '22,000',
      'parklane': '40,000',
      'lotusIriga': '20,000',
      'chosenIriga': '22,000',
      'nabuaDryGoods': '18,000',
      'daet': '20,000',
      'legazpi': '11,800',
      'goa': '15,000',
      'sipocot': '19,000',
    },
  ];

  // Controllers for the date pickers
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();

  // Method to calculate totals for each store and overall
  Map<String, int> _calculateTotals() {
    final totals = <String, int>{};
    int overallTotal = 0;

    for (var entry in _salesData) {
      for (var key in entry.keys) {
        if (key != 'date') {
          int value = int.parse(entry[key]!.replaceAll(',', ''));
          totals[key] = (totals[key] ?? 0) + value;
          overallTotal += value;
        }
      }
    }
    totals['overall'] = overallTotal;
    return totals;
  }

  // Method to generate reports between selected dates
  void _generateReports() {
    if (fromDate != null && toDate != null) {
      String formattedFromDate = DateFormat('MMM.dd.yyyy').format(fromDate!);
      String formattedToDate = DateFormat('MMM.dd.yyyy').format(toDate!);

      // Displaying a dialog with the report information
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Generated Reports'),
          content: Text(
              'Reports generated from $formattedFromDate to $formattedToDate.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // Show a snackbar if dates are not selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both dates.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totals = _calculateTotals();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 185, 34, 23),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/images/logo_1.png',
              height: 60,
            ),
            Text(
              'Monthly Sales Report',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
     body: Container(
  color: Colors.white, // Set the background color to white
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title row with an icon and header text
        Row(
          children: [
            const Icon(
              Icons.assessment,
              color: Colors.blue,
              size: 30,
            ),
            const SizedBox(width: 8),
            Text(
              'MONTHLY SALES REPORT',
              style: GoogleFonts.poppins(
                color: const Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Container for date pickers and the "Generate Reports" button
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Row(
            children: [
              // From date picker
              _datePicker(context, 'From:', fromDateController,
                  (date) => setState(() => fromDate = date)),
              const SizedBox(width: 10),

              // To date picker
              _datePicker(context, 'To:', toDateController,
                  (date) => setState(() => toDate = date)),
              const Spacer(),

              // Generate Reports button
              ElevatedButton(
                onPressed: _generateReports,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Generate Reports',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Data table displaying sales data
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth, // Expands dynamically to screen width
                    ),
                    child: DataTable(
                      columnSpacing: constraints.maxWidth / _salesData[0].length, // Adjusts spacing dynamically
                      headingRowColor: WidgetStateProperty.all(Colors.blue.shade100),
                      headingTextStyle: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      columns: _salesData[0].keys.map((key) {
                        return DataColumn(
                          label: Expanded(
                            child: Center(
                              child: Text(
                                key.toUpperCase(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      rows: _salesData.map((data) {
                        data.entries
                            .where((entry) => entry.key != 'date')
                            .fold(0, (sum, entry) => sum + int.parse(entry.value.replaceAll(',', '')));

                        return DataRow(
                          cells: data.entries.map((entry) {
                            return DataCell(
                              Center(
                                child: Text(
                                  entry.key == 'date'
                                      ? entry.value
                                      : '₱${NumberFormat().format(int.parse(entry.value.replaceAll(',', '')))}',
                                  style: entry.key == 'TOTAL'
                                      ? const TextStyle(fontWeight: FontWeight.bold)
                                      : null,
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Totals row
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TOTAL PER STORE:',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: _salesData[0]
                    .keys
                    .where((key) => key != 'date')
                    .map((key) => Text(
                          '$key: ₱${NumberFormat().format(totals[key] ?? 0)}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.black),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('OVERALL SALES:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black)),
                  Text('₱${NumberFormat().format(totals['overall'])}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
     )
    );
  }

  // Widget for the date picker field
  Widget _datePicker(BuildContext context, String label,
      TextEditingController controller, Function(DateTime?) onDateSelected) {
    return Row(
      children: [
        // Label for the date picker
        Text(label,
            style:
                GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(width: 10),

        // TextField for displaying the selected date
        Container(
          width: 160,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            style: GoogleFonts.poppins(fontSize: 12),
            textAlignVertical: const TextAlignVertical(y: -0.8),
            textAlign: TextAlign.left,
            decoration: const InputDecoration(
              border: InputBorder.none,
              suffixIcon: Icon(Icons.calendar_today, size: 18),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            ),
            readOnly: true,
            onTap: () async {
              // Display date picker dialog
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null) {
                controller.text = DateFormat('MMM.dd.yyyy').format(pickedDate);
                onDateSelected(pickedDate);
              }
            },
          ),
        ),
      ],
    );
  }
}
