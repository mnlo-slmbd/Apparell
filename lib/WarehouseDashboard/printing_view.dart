import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Order List',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Poppins',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const PrintingView(),
      },
    );
  }
}

class PrintingView extends StatefulWidget {
  const PrintingView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PrintingViewState createState() => _PrintingViewState();
}

class _PrintingViewState extends State<PrintingView>
    with SingleTickerProviderStateMixin {
  List<List<String>> tableData = [];
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDoneButtonPressed() async {
    await _controller.forward(); // Start fade-out animation
    // ignore: use_build_context_synchronously
    Navigator.pop(context); // Navigate back to the previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 185, 34, 23),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/images/logo_1.png',
              height: 60,
            ),
            Text(
              'Order List',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bar_chart,
                            color: Colors.blue, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          "Order List",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InfoRow(
                                      title: "Store Name",
                                      value: "Lotus Iriga"),
                                  InfoRow(
                                      title: "Contact Number",
                                      value: "+63950 888 9999"),
                                  InfoRow(
                                      title: "Email Address",
                                      value: "lotusiriga@gmail.com"),
                                  InfoRow(
                                      title: "Address", value: "Iriga City"),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InfoRow(title: "Order ID", value: "0001"),
                                  InfoRow(
                                      title: "Customer Name",
                                      value: "Alice Guo"),
                                  InfoRow(
                                      title: "Team Name",
                                      value: "Team Phoenix"),
                                  InfoRow(
                                      title: "Due Date",
                                      value: "September 30, 2024"),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // DataTable Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity, // Full width
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTableSection(
                          data: tableData.isEmpty ? data1 : tableData,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Design Reference and Remarks Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Design Card
                    Expanded(
                      flex: 3,
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Container(
                          height: 300, // Card height
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'assets/images/sample_jersey.png', // Replace with your image asset
                            fit: BoxFit.contain, // Fit image neatly
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Remarks Section
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Remarks:",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              maxLines: 3,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Add your remarks here...",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Done Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: _onDoneButtonPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(120, 50), // Adjusted button size
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      "DONE",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String title;
  final String value;

  const InfoRow({required this.title, required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              "$title:",
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DataTableSection extends StatelessWidget {
  final List<List<String>> data;

  const DataTableSection({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return DataTable(
      headingRowColor:
          WidgetStateColor.resolveWith((states) => Colors.blue.shade100),
      columnSpacing: 40, // Increased spacing for alignment
      columns: const [
        DataColumn(label: Text("SURNAME", style: _headerTextStyle)),
        DataColumn(label: Text("#", style: _headerTextStyle)),
        DataColumn(label: Text("POSITION", style: _headerTextStyle)),
        DataColumn(label: Text("SIZE", style: _headerTextStyle)),
        DataColumn(label: Text("NBA/REG", style: _headerTextStyle)),
        DataColumn(label: Text("TYPE", style: _headerTextStyle)),
        DataColumn(label: Text("NECK TYPE", style: _headerTextStyle)),
        DataColumn(label: Text("SHORT", style: _headerTextStyle)),
      ],
      rows: data.map((row) {
        return DataRow(
          cells: row.map((cell) {
            return DataCell(
              Text(cell,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 12)),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

const TextStyle _headerTextStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontFamily: 'Poppins',
  fontSize: 12,
);

final List<List<String>> data1 = [
  ["Millena", "1", "Captain", "XS", "NBA", "Jersey", "V-Neck", "XS"],
  ["Dizon", "2", "Muse", "S", "NBA", "Jersey", "V-Neck", "S"],
  ["Obelidor", "3", "Player", "M", "NBA", "Jersey", "V-Neck", "M"],
  ["Ortiz", "4", "Player", "L", "NBA", "Jersey", "V-Neck", "L"],
  ["Salumbides", "5", "Player", "XL", "NBA", "Jersey", "V-Neck", "XL"],
  ["Rosete", "6", "Player", "2XL", "NBA", "Jersey", "V-Neck", "2XL"],
];
