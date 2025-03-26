// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_pdfview/flutter_pdfview.dart'; // Correct import for PDFViewerScreen

class Inventory extends StatelessWidget {
  const Inventory({super.key});

  @override
  Widget build(BuildContext context) {
    return const InventoryPage(); // ✅ This will now be inside the existing MaterialApp
  }
}

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  DateTime? fromDate;
  DateTime? toDate;
  List<Map<String, dynamic>> _productList = [];

  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts({String? fromDate, String? toDate}) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/Apparell_backend/get_products_inventory.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'from_date': fromDate, 'to_date': toDate}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> products = json.decode(response.body);
        setState(() {
          _productList = products.map((product) {
            return {
              'id': product['id'].toString(),
              'name': product['name'] ?? '',
              'description': product['description'] ?? '',
              'price': product['price'].toString(),
              'unit': product['unit'] ?? '',
              'stock': product['stock'].toString(),
              'value': product['value'].toString(),
              'supplier': product['supplier'] ?? '',
              'category': product['category'] ?? '',
              'dateAdded': product['date_added'] ?? '',
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to fetch products.');
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  void _addProductToDatabase(Map<String, dynamic> newProduct) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/Apparell_backend/add_product.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(newProduct),
      );

      if (response.statusCode == 200) {
        setState(() {
          _productList.add(newProduct);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product added successfully.'),
          ),
        );
      } else {
        throw Exception('Failed to add product.');
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while adding the product.'),
        ),
      );
    }
  }

  void _addNewProduct() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final unitController = TextEditingController();
    final stockController = TextEditingController();
    final supplierController = TextEditingController();
    final categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Price'),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(labelText: 'Unit'),
              ),
              TextField(
                controller: stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stock Quantity'),
              ),
              TextField(
                controller: supplierController,
                decoration: const InputDecoration(labelText: 'Supplier'),
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isEmpty ||
                  descriptionController.text.isEmpty ||
                  priceController.text.isEmpty ||
                  unitController.text.isEmpty ||
                  stockController.text.isEmpty ||
                  supplierController.text.isEmpty ||
                  categoryController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All fields are required.'),
                  ),
                );
                return;
              }

              final double price = double.tryParse(priceController.text) ?? 0.0;
              final int stock = int.tryParse(stockController.text) ?? 0;
              final double value = price * stock;
              final String dateAdded =
                  DateFormat('yyyy-MM-dd').format(DateTime.now());

              final newProduct = {
                'name': nameController.text,
                'description': descriptionController.text,
                'price': price.toStringAsFixed(2),
                'unit': unitController.text,
                'stock': stock.toString(), // Use 'stock' for quantity
                'value': value.toStringAsFixed(2),
                'supplier': supplierController.text,
                'category': categoryController.text,
                'dateAdded': dateAdded,
              };

              _addProductToDatabase(newProduct);
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 185, 34, 23),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(
                context); // ✅ This will now properly return to the previous screen
          },
        ),
        title: Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Inventory',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory_2, color: Colors.blue, size: 30),
                const SizedBox(width: 8),
                Text(
                  'INVENTORY LIST',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _datePicker(context, 'From:', fromDateController,
                    (date) => setState(() => fromDate = date)),
                const SizedBox(width: 10),
                _datePicker(context, 'To:', toDateController,
                    (date) => setState(() => toDate = date)),
                const Spacer(),
                ElevatedButton(
                  onPressed: _generateReport, // ✅ Call the function
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Generate Reports',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addNewProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Add New Product',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 105,
                  headingRowColor: WidgetStateColor.resolveWith(
                      (states) => Colors.blue.shade100),
                  dataRowColor:
                      WidgetStateColor.resolveWith((states) => Colors.white),
                  columns: [
                    DataColumn(
                      label: Text(
                        'Date Added',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13, // You can adjust the size if needed
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Name',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Description',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Price',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Unit',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Qty',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Value',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Supplier',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Category',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                  rows: _productList.map((product) {
                    return DataRow(
                      cells: [
                        DataCell(Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Text(product['dateAdded'] ?? ''),
                        )),
                        DataCell(Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Text(product['name'] ?? ''),
                        )),
                        DataCell(Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Text(product['description'] ?? ''),
                        )),
                        DataCell(Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Text(product['price'] ?? ''),
                        )),
                        DataCell(Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Text(product['unit'] ?? ''),
                        )),
                        DataCell(Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Text(product['stock'] ?? ''),
                        )),
                        DataCell(Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Text(product['value'] ?? ''),
                        )),
                        DataCell(Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Text(product['supplier'] ?? ''),
                        )),
                        DataCell(Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Row(
                            children: [
                              Text(product['category'] ?? ''),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Product'),
                                      content: const Text(
                                          'Are you sure you want to delete this product?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            _deleteProduct(product['id']);
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
void _generateReport() async {
  if (fromDate == null || toDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select a date range first!')),
    );
    return;
  }

  try {
    final response = await http.post(
      Uri.parse('http://localhost/Apparell_backend/generate_report.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'from_date': DateFormat('yyyy-MM-dd').format(fromDate!),
        'to_date': DateFormat('yyyy-MM-dd').format(toDate!),
      }),
    );

    if (response.statusCode == 200) {
      final pdfBytes = response.bodyBytes;

      // Save the PDF
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/inventory_report.pdf';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      // Open the PDF
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFView(filePath: filePath),
        ),
      );
    } else {
      throw Exception('Failed to generate report.');
    }
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error generating report: $error')),
    );
  }
}

  void _deleteProduct(String productId) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/Apparell_backend/delete_product.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': productId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _productList.removeWhere((product) => product['id'] == productId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product deleted successfully.'),
          ),
        );
      } else {
        throw Exception('Failed to delete product.');
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while deleting the product.'),
        ),
      );
    }
  }

  Widget _datePicker(BuildContext context, String label,
      TextEditingController controller, Function(DateTime?) onDateSelected) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center, // Aligns label and field
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 10),
        Container(
          width: 160,
          height: 35, // Set height for consistency
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            style: GoogleFonts.poppins(fontSize: 12),
            textAlignVertical: TextAlignVertical.center, // Ensures text is centered
            textAlign: TextAlign.left, // Aligns text to the left
            decoration: const InputDecoration(
              border: InputBorder.none,
              suffixIcon: Icon(Icons.calendar_today, size: 16), // Calendar icon
              suffixIconConstraints: BoxConstraints(
                minWidth: 30,
                minHeight: 30,
              ),
              contentPadding: EdgeInsets.only(left: 10, bottom: 8), // Aligns with label
            ),
            readOnly: true,
            onTap: () async {
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

