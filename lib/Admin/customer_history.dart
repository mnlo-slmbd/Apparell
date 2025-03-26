import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class CustomerHistory extends StatefulWidget {
  const CustomerHistory({super.key});

  @override
  State<CustomerHistory> createState() => _CustomerHistoryState();
}

class _CustomerHistoryState extends State<CustomerHistory> {
  List<dynamic> customers = [];
  Map<String, dynamic> customerOrderHistory = {};
  int selectedCustomerIndex = 0;
  bool isLoading = true;

  // Fetch customer and order history data from the server
  Future<void> fetchCustomerData() async {
    try {
      final url = Uri.parse(
          "http://localhost/Apparell_backend/get_customers.php"); // Use 10.0.2.2 for Android emulator
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          setState(() {
            customers = data['customers'];
            customerOrderHistory = data['customerOrderHistory'];
          });

          // Log customers for debugging
          for (var customer in customers) {
            // ignore: avoid_print
            print('Customer: ${customer['name']}, ID: ${customer['id']}');
          }
        } else {
          throw Exception(data['message'] ?? 'Failed to load data.');
        }
      } else {
        throw Exception('Failed to connect to the server.');
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Ensure value is not null
  String safeValue(String? value) {
    return value ?? 'N/A';
  }

  // Update customer details
  Future<void> updateCustomerData(Map<String, String> updatedCustomer) async {
    try {
      final url = Uri.parse(
          "http://localhost/Apparell_backend/update_customer.php"); // Update endpoint
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedCustomer),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Customer updated successfully!')),
          );
          fetchCustomerData(); // Refresh customer data
        } else {
          throw Exception(data['message'] ?? 'Failed to update customer.');
        }
      } else {
        throw Exception('Failed to connect to the server.');
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void showUpdateDialog() {
    // Fetch the selected customer
    final customer = customers[selectedCustomerIndex];

    // Ensure the customer has a valid ID
    if (customer['id'] == null || customer['id'].toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Customer ID is null or invalid')),
      );
      return;
    }

    // Retrieve the customer fields for the dialog
    final TextEditingController nameController =
        TextEditingController(text: customer['name'] ?? '');
    final TextEditingController phoneController =
        TextEditingController(text: customer['contact_number'] ?? '');
    final TextEditingController emailController =
        TextEditingController(text: customer['email'] ?? '');
    final TextEditingController addressController =
        TextEditingController(text: customer['address'] ?? '');

    // Display the update dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Customer'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                // Call updateCustomerData with the correct customer data
                updateCustomerData({
                  'id': customer['id'].toString(),
                  'name': nameController.text,
                  'phone': phoneController.text,
                  'email': emailController.text,
                  'address': addressController.text,
                });
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchCustomerData();
  }

  String formatDate(String? date) {
    if (date == null || date == "--") return "N/A";
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('MMM dd, yyyy').format(parsedDate);
    } catch (e) {
      return "N/A";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CUSTOMERS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            fontSize: 15,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 185, 34, 23),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: showUpdateDialog,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : customers.isEmpty
              ? const Center(
                  child: Text(
                    'No customers available',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                    ),
                  ),
                )
              : Row(
                  children: [
                    // Sidebar with customer list
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.grey[200],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Icon(Icons.people, color: Colors.grey[800]),
                                  const SizedBox(width: 8.0),
                                  const Flexible(
                                    child: Text(
                                      'CUSTOMERS',
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(),
                            Expanded(
                              child: ListView.builder(
                                itemCount: customers.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: Checkbox(
                                      value: selectedCustomerIndex == index,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          selectedCustomerIndex = index;
                                        });
                                      },
                                      activeColor: Colors.black,
                                    ),
                                    title: Text(
                                      safeValue(customers[index]['name']),
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                      ),
                                    ),
                                    subtitle: Text(
                                      safeValue(customers[index]['phone']),
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Customer details and order history
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CUSTOMER DETAILS',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'Name: ${safeValue(customers[selectedCustomerIndex]['name'])}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'Contact Number: ${safeValue(customers[selectedCustomerIndex]['phone'])}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'Address: ${safeValue(customers[selectedCustomerIndex]['address'])}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'Email Address: ${safeValue(customers[selectedCustomerIndex]['email'])}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            const Text(
                              'ORDER HISTORY',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Expanded(
                              child: (customerOrderHistory[safeValue(
                                              customers[selectedCustomerIndex]
                                                  ['name'])] ??
                                          [])
                                      .isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No order history available',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                        ),
                                      ),
                                    )
                                  : SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        columns: const [
                                          DataColumn(
                                            label: Expanded(
                                              child: Text(
                                                'Team Name',
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Expanded(
                                              child: Text(
                                                'Date Ordered',
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Expanded(
                                              child: Text(
                                                'Date Delivered',
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: Expanded(
                                              child: Text(
                                                'Status',
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                        rows: (customerOrderHistory[safeValue(
                                                    customers[
                                                            selectedCustomerIndex]
                                                        ['name'])] ??
                                                [])
                                            .map<DataRow>((order) {
                                          return DataRow(cells: [
                                            DataCell(Text(
                                              safeValue(order['team']),
                                              style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 12),
                                            )),
                                            DataCell(Text(
                                              formatDate(order['ordered']),
                                              style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 12),
                                            )),
                                            DataCell(Text(
                                              formatDate(order['delivered']),
                                              style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 12),
                                            )),
                                            DataCell(Text(
                                              safeValue(order['status']),
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 12,
                                                color: (order['status'] ==
                                                            'Active' ||
                                                        order['status'] ==
                                                            'Rush')
                                                    ? Colors.green
                                                    : Colors.blue,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )),
                                          ]);
                                        }).toList(),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
