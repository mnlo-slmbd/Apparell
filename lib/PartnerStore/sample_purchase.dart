// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'quotation_page.dart';

void main() {
  runApp(const PurchaseOrderFormApp());
}

class PurchaseOrderFormApp extends StatelessWidget {
  const PurchaseOrderFormApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PurchaseOrderForms(
        storeName: '',
      ),
    );
  }
}

class PurchaseOrderForms extends StatefulWidget {
  final String storeName;

  const PurchaseOrderForms({super.key, required this.storeName});

  @override
  _PurchaseOrderFormState createState() => _PurchaseOrderFormState();
}

class _PurchaseOrderFormState extends State<PurchaseOrderForms> {
  String selectedOrderType = 'Regular Order';
  bool isRushOrder = false;
  bool isNewOrderChecked = false;
  bool isAdditionalOrderChecked = false;
  String selectedMOP = 'GCash';

  List<Map<String, dynamic>> provinces = [];
  List<Map<String, dynamic>> cities = [];

  String? selectedProvinceId;
  String? selectedCityId;

  final List<Map<String, dynamic>> orderDetails = [];
  final TextEditingController downpaymentController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController orderIdController = TextEditingController();
  final TextEditingController dateOrderController = TextEditingController(
    text: DateFormat('MMM. dd, yyyy').format(DateTime.now()),
  );
  final TextEditingController storeController = TextEditingController();
  final TextEditingController teamNameController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController emailAddressController = TextEditingController();

  double totalSale = 0.0;
  double balance = 0.0;
  List<Map<String, dynamic>> products = [];

  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'en_PH', symbol: '₱');

  String getStoreCode(String storeName) {
    final words = storeName.trim().split(' ');
    String code =
        words.map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join();

    return code.length >= 2 ? code : 'SMX';
  }

  String getFormattedAddress() {
    final province = provinces.firstWhere(
      (p) => p['id'].toString() == selectedProvinceId,
      orElse: () => {"name": ""},
    );
    final city = cities.firstWhere(
      (c) => c['id'].toString() == selectedCityId,
      orElse: () => {"name": ""},
    );

    String provinceName = province['name'] ?? '';
    String cityName = city['name'] ?? '';

    if (provinceName.isEmpty && cityName.isEmpty) return '';

    return "$provinceName, $cityName";
  }

  Future<void> fetchProvinces() async {
    final response = await http.get(Uri.parse(
        'http://localhost/apparell/Apparell_backend/fetch_provinces.php'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      setState(() {
        provinces = List<Map<String, dynamic>>.from(data);
        print("✅ Provinces loaded: ${provinces.length}");
      });
    }
  }

  Future<void> fetchCities(String provinceId) async {
    final response = await http.get(Uri.parse(
        'http://localhost/apparell/Apparell_backend/fetch_cities.php?province_id=$provinceId'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      setState(() {
        cities = List<Map<String, dynamic>>.from(data);
      });
    }
  }

  Future<String> generateUniqueOrderId() async {
    String storeCode = getStoreCode(widget.storeName);

    final response = await http.get(Uri.parse(
        'http://localhost/apparell/Apparell_backend/check_order_id.php?storeCode=$storeCode'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success' && data['last_order_id'] != null) {
        String lastOrderId = data['last_order_id'];
        int lastNumber = int.tryParse(lastOrderId.split('-').last) ?? 0;
        return "$storeCode-${(lastNumber + 1).toString().padLeft(3, '0')}";
      }
    }

    // fallback
    return "$storeCode-001";
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
    assignOrderId();
    fetchProvinces();

    dateOrderController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());

    storeController.text = widget.storeName;
  }

  void assignOrderId() async {
    String generatedOrderId = await generateUniqueOrderId();
    setState(() {
      orderIdController.text = generatedOrderId;
    });
  }

  Future<bool> saveOrderToDatabase() async {
    final url =
        Uri.parse('http://localhost/apparell/Apparell_backend/save_order.php');

    String formattedDateOrder = '';
    try {
      DateTime parsedDateOrder =
          DateFormat('MMM. dd, yyyy').parse(dateOrderController.text);
      formattedDateOrder = DateFormat('yyyy-MM-dd').format(parsedDateOrder);
    } catch (e) {
      formattedDateOrder = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }

    String formattedDueDate = '';
    if (dueDateController.text.isNotEmpty) {
      try {
        DateTime parsedDueDate =
            DateFormat('MMMM dd, yyyy').parse(dueDateController.text);
        formattedDueDate = DateFormat('yyyy-MM-dd').format(parsedDueDate);
      } catch (e) {
        formattedDueDate = '';
      }
    }

    final response = await http.post(
      url,
      body: {
        "order_id": orderIdController.text,
        "date_order": formattedDateOrder,
        "store": storeController.text,
        "team_name": teamNameController.text,
        "due_date": formattedDueDate,
        "customer_name": customerNameController.text,
        "contact_number": contactNumberController.text,
        "address": getFormattedAddress(),
        "email": emailAddressController.text,
        "order_type": selectedOrderType,
        "is_new_order": isNewOrderChecked ? "1" : "0",
        "is_additional_order": isAdditionalOrderChecked ? "1" : "0",
        "total_sale": totalSale.toString(),
        "downpayment": downpaymentController.text,
        "discount": discountController.text,
        "balance": balance.toString(),
        "mop": selectedMOP,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data["success"]) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Order saved successfully!")),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save order: ${data["message"]}")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Server error: ${response.statusCode}")),
      );
    }
    return false;
  }

  void confirmOrder() async {
    String newOrderId = await generateUniqueOrderId();
    setState(() {
      orderIdController.text = newOrderId;
    });

    bool orderSaved = await saveOrderToDatabase();

    if (orderSaved) {
      assignOrderId();
    }
  }

  Future<void> fetchProducts() async {
    const String url =
        'http://localhost/apparell/Apparell_backend/fetch_product.php';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() {
            products = List<Map<String, dynamic>>.from(data);
          });
        } else if (data is Map &&
            data.containsKey('status') &&
            data['status'] == 'success' &&
            data.containsKey('products')) {
          setState(() {
            products = List<Map<String, dynamic>>.from(data['products']);
          });
        }
      } else {
        if (kDebugMode) {
          print('Failed to load products. Status code: ${response.statusCode}');
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching products: $error');
      }
    }
  }

  void addNewItem() {
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No products available. Please try again later.')),
      );
      return;
    }

    setState(() {
      orderDetails.add({
        "item": "Uniform",
        "description": products.first['name'],
        "qty": 1,
        "origPrice": products.first['price'],
        "unitPrice": products.first['price'] + (isRushOrder ? 50 : 0),
        "total": products.first['price'] + (isRushOrder ? 50 : 0),
      });
    });
    computeTotals();
  }

  void deleteItem(int index) {
    setState(() {
      orderDetails.removeAt(index);
      computeTotals();
    });
  }

  void computeTotals() {
    double overallTotal = 0.0;
    for (var order in orderDetails) {
      order["total"] =
          order["qty"] * order["unitPrice"]; // Total = qty x unitPrice
      overallTotal += order["total"];
    }

    double discount = double.tryParse(discountController.text) ?? 0.0;
    double downpayment = double.tryParse(downpaymentController.text) ?? 0.0;

    setState(() {
      totalSale = overallTotal;
      balance = totalSale - discount - downpayment; // Balance calculation
    });
  }

  Future<void> selectDueDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.red, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        // Update controller with formatted date
        dueDateController.text = DateFormat('MMMM dd, yyyy').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set body background to white
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 185, 34, 23),
        elevation: 0, // Removes the shadow
        automaticallyImplyLeading: false, // Hides the default back button
        title: Row(
          mainAxisAlignment:
              MainAxisAlignment.start, // Aligns content to the start
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(
                    context, '/order_page'); // Navigate to the order page
              },
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 10.0), // Adjust left padding as needed
              child: Image.asset(
                'assets/images/logo_1.png',
                height: 60, // Adjust height for proper alignment
              ),
            ),
            const SizedBox(
                width: 10), // Add spacing between logo and next widget
            const Text(
              'PURCHASE ORDER FORM',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Type Options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildOrderTypeButton('Regular Order'),
                buildOrderTypeButton('Rush Order'),
                buildOrderTypeButton('Big Order'),
                buildOrderTypeButton('PhilGeps'),
              ],
            ),
            const SizedBox(height: 20),
            // Order Information Section
            buildOrderInformation(),
            const SizedBox(height: 20),
            // Customer Information Section
            buildCustomerInformation(),
            const SizedBox(height: 20),
            // Order Details
            buildOrderDetails(),
            const SizedBox(height: 20),
            buildSummary(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildOrderTypeButton(String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOrderType = label;
          isRushOrder = selectedOrderType == 'Rush Order';

          // Adjust pricing for Rush Order
          for (var order in orderDetails) {
            order["unitPrice"] = order["origPrice"] + (isRushOrder ? 50 : 0);
            order["total"] = order["qty"] * order["unitPrice"];
          }
          computeTotals();
        });
      },
      child: Container(
        width: 100, // Adjust width as needed
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          color: Colors.white, // Always white background
          borderRadius:
              BorderRadius.circular(4), // Rounded corners for a cleaner look
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: selectedOrderType == label ? Colors.black : Colors.white,
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
              ),
              child: selectedOrderType == label
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black, // Always black text color
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOrderInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ORDER INFORMATION',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInlineTextField(
                    label: 'ORDER ID',
                    controller: orderIdController,
                    isEditable: true,
                    textColor: Colors.red,
                  ),
                  _buildInlineTextField(
                    label: 'DATE ORDER',
                    controller: dateOrderController,
                    isDateInput: false,
                  ),
                  _buildInlineTextField(
                    label: 'STORE',
                    controller: storeController,
                    isEditable: true,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInlineTextField(
                    label: 'TEAM NAME',
                    controller: teamNameController,
                    isEditable: true,
                  ),
                  _buildInlineTextField(
                    label: 'DUE DATE',
                    controller: dueDateController,
                    isDateInput: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInlineTextField({
    required String label,
    required TextEditingController controller,
    bool isEditable = true, // Default to editable for text fields
    bool isDateInput = false,
    Color textColor = Colors.black,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextFormField(
                controller: controller,
                readOnly: isDateInput, // Non-editable only for date input
                textAlign: TextAlign.left,
                decoration: InputDecoration(
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                  border: InputBorder.none,
                  suffixIcon: isDateInput
                      ? IconButton(
                          icon: const Icon(Icons.calendar_today, size: 18),
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                              builder: (context, child) {
                                return Theme(
                                  data: ThemeData.light().copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Colors.red, // Header color
                                      onPrimary: Colors.white, // Text color
                                      onSurface: Colors.black, // Date color
                                    ),
                                    dialogBackgroundColor: Colors.white,
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (pickedDate != null) {
                              setState(() {
                                controller.text = DateFormat('MMMM dd, yyyy')
                                    .format(pickedDate);
                              });
                            }
                          },
                        )
                      : null, // No calendar icon for regular text fields
                ),
                style: TextStyle(
                  fontSize: 14,
                  color: isEditable ? textColor : Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCustomerInformation() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer Information Fields
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CUSTOMER INFORMATION',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 10),
                buildLabeledTextField('Customer Name', customerNameController),
                const SizedBox(height: 10),
                buildLabeledTextField(
                    'Contact Number', contactNumberController),
                const SizedBox(height: 10),
                buildDropdownField(
                  label: 'Province',
                  items: provinces,
                  selectedId: selectedProvinceId,
                  onChanged: (value) {
                    setState(() {
                      selectedProvinceId = value;
                      selectedCityId = null; // ✅ Clear selected city
                      cities = [];
                    });
                    fetchCities(value!);
                  },
                ),
                const SizedBox(height: 10),
                buildDropdownField(
                  label: 'City/Municipality',
                  items: cities,
                  selectedId: selectedCityId,
                  onChanged: (value) {
                    setState(() {
                      selectedCityId = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                buildLabeledTextField('Email Address', emailAddressController),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Classification Section
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CLASSIFICATION',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: isNewOrderChecked,
                      activeColor: Colors.black, // <-- Make checkbox black
                      checkColor:
                          Colors.white, // <-- Tick mark color (optional)
                      onChanged: (value) {
                        setState(() {
                          isNewOrderChecked = value ?? false;
                          if (isNewOrderChecked) {
                            isAdditionalOrderChecked = false;
                          }
                        });
                      },
                    ),
                    const Text('New Order'),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: isAdditionalOrderChecked,
                      onChanged: (value) {
                        setState(() {
                          isAdditionalOrderChecked = value ?? false;
                          if (isAdditionalOrderChecked) {
                            isNewOrderChecked = false;
                          }
                        });
                      },
                    ),
                    const Text('Additional Order'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLabeledTextField(String label, TextEditingController controller) {
    return Row(
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildOrderDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'ORDER DETAILS',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: addNewItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white, // Text color set to white
              ),
              child: const Text('+ ADD NEW ITEM'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Table(
          border: TableBorder.all(color: Colors.black26),
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(3),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(1),
            4: FlexColumnWidth(1),
            5: FlexColumnWidth(1),
            6: FlexColumnWidth(1), // Column for the delete button
          },
          children: [
            // Header Row
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[300]),
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('ITEM',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('DESCRIPTION',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('QTY',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('ORIG PRICE',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('UNIT PRICE',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('TOTAL',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('ACTION',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            // Dynamic Rows
            ...orderDetails.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> order = entry.value;
              return TableRow(
                children: [
                  Padding(
                    //Items
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButton<String>(
                      value: order["item"] ?? 'Uniform',
                      isExpanded: true,
                      onChanged: (value) {
                        setState(() {
                          order["item"] = value!;
                        });
                      },
                      items: [
                        'Uniform',
                        'Cap',
                        'Trophy',
                        'Stickers',
                        'Tarpaulin',
                        'Embroidery',
                        'Others'
                      ].map((item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                    ),
                  ), //Items
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: order["description"],
                      onChanged: (value) {
                        final product = products.firstWhere(
                            (prod) => prod['name'] == value,
                            orElse: () => {"name": "", "price": 0.0});
                        setState(() {
                          order["description"] = product['name'];
                          order["origPrice"] = product['price'];
                          order["unitPrice"] =
                              product['price'] + (isRushOrder ? 50 : 0);
                          order["total"] = order["qty"] * order["unitPrice"];
                          computeTotals();
                        });
                      },
                      items: products
                          .map((prod) => DropdownMenuItem<String>(
                                value: prod['name'] as String,
                                child: Text(prod['name']),
                              ))
                          .toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          order["qty"] = int.tryParse(value) ?? 1;
                          order["total"] = order["qty"] * order["unitPrice"];
                          computeTotals();
                        });
                      },
                      decoration: const InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(order["origPrice"].toStringAsFixed(2)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(order["unitPrice"].toStringAsFixed(2)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(currencyFormat.format(order["total"])),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        deleteItem(index); // Call delete function
                      },
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget buildSummary() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 350, // Fixed width for cleaner alignment
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SUMMARY',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
                label: 'Total:',
                value: currencyFormat.format(totalSale),
                isBold: true),
            const SizedBox(height: 12),
            _buildInputRow(
                'Downpayment:',
                TextField(
                  controller: downpaymentController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  onChanged: (value) => computeTotals(),
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  ),
                  style: const TextStyle(fontSize: 14),
                )),
            const SizedBox(height: 12),
            _buildInputRow(
                'MOP:',
                DropdownButtonFormField<String>(
                  value: selectedMOP,
                  onChanged: (value) {
                    setState(() {
                      selectedMOP = value!;
                    });
                  },
                  items: const [
                    DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                    DropdownMenuItem(value: 'GCash', child: Text('GCash')),
                    DropdownMenuItem(value: 'Maya', child: Text('Maya')),
                    DropdownMenuItem(value: 'Bank', child: Text('Bank')),
                    DropdownMenuItem(value: 'Cheque', child: Text('Cheque')),
                  ],
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  ),
                  style: const TextStyle(fontSize: 14),
                )),
            const SizedBox(height: 12),
            _buildInputRow(
                'Discount:',
                TextField(
                  controller: discountController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  onChanged: (value) => computeTotals(),
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  ),
                  style: const TextStyle(fontSize: 14),
                )),
            const SizedBox(height: 12),
            _buildSummaryRow(
              label: 'Balance:',
              value: currencyFormat.format(balance),
              isBold: true,
              isRed: true,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuotationPage(
                        orderDetails: orderDetails,
                        totalSale: totalSale,
                        customerName: customerNameController.text,
                        contactNumber: contactNumberController.text,
                        address: getFormattedAddress(),
                        email: emailAddressController.text,
                        orderType: selectedOrderType,
                        balance: balance,
                        orderId: orderIdController.text,
                        store: storeController.text,
                        teamName: teamNameController.text,
                        deliveryDate: dueDateController.text,
                        dateOrder: dateOrderController.text,
                        mop: selectedMOP,
                        downpayment:
                            double.tryParse(downpaymentController.text) ?? 0.0,
                        isNewOrderChecked: isNewOrderChecked,
                        isAdditionalOrderChecked: isAdditionalOrderChecked,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text(
                  'GENERATE QUOTATION',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    bool isBold = false,
    bool isRed = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isRed ? Colors.red : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildInputRow(String label, Widget inputWidget) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        SizedBox(
          width: 150,
          child: inputWidget,
        ),
      ],
    );
  }

  Widget buildDropdownField({
    required String label,
    required List<Map<String, dynamic>> items,
    required String? selectedId,
    required Function(String?) onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: selectedId != null &&
                    items.any((e) => e['id'].toString() == selectedId)
                ? selectedId
                : null,
            items: items.map<DropdownMenuItem<String>>((item) {
              return DropdownMenuItem<String>(
                value: item['id'].toString(),
                child: Text(item['name']),
              );
            }).toList(),
            onChanged: onChanged,
            dropdownColor: Colors.white, // <-- Set dro
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}
