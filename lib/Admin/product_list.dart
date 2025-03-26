import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  // Fetch products from the database
  Future<void> _fetchProducts() async {
    final url = Uri.parse(
        'http://localhost/apparell/Apparell_backend/get_products.php');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        _products = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      });
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to fetch products'),
      ));
    }
  }

  // Add a new product to the database
  Future<void> _addProductToDatabase(String name, String price) async {
    final url =
        Uri.parse('http://localhost/apparell/Apparell_backend/add_product.php');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'price': double.parse(price),
        'status': 'Draft',
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['status'] == 'success') {
        await _fetchProducts();
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message']),
        ));
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message']),
        ));
      }
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to add product'),
      ));
    }
  }

  // Delete a product from the database
  Future<void> _deleteProductFromDatabase(int id) async {
    final url = Uri.parse(
        'http://localhost/apparell/Apparell_backend/delete_product.php');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['status'] == 'success') {
        await _fetchProducts();
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message']),
        ));
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message']),
        ));
      }
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to delete product'),
      ));
    }
  }

  // Confirm before deleting
  void _confirmDeleteProduct(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Product"),
        content: const Text("Are you sure you want to delete this product?"),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close the dialog
              await _deleteProductFromDatabase(id); // Delete the product
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Close the dialog
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  // Open a dialog to add a new product
  void _addProduct() {
    String productName = '';
    String productPrice = '';

    showDialog(
      context: context,
      builder: (context) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 300),
          padding: MediaQuery.of(context).viewInsets,
          child: AlertDialog(
            title: const Text("Add Product"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Product Name'),
                  onChanged: (value) => productName = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Product Price'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => productPrice = value,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (productName.isNotEmpty && productPrice.isNotEmpty) {
                    await _addProductToDatabase(productName, productPrice);
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  }
                },
                child: const Text("Add"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancel"),
              ),
            ],
          ),
        );
      },
    );
  }

  // Edit a product in the database
  Future<void> _editProductInDatabase(
      int id, String name, String price, String status) async {
    final url = Uri.parse(
        'http://localhost/apparell/Apparell_backend/update_product.php');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': id,
        'name': name,
        'price': double.parse(price),
        'status': status,
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['status'] == 'success') {
        await _fetchProducts();
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message']),
        ));
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message']),
        ));
      }
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to update product'),
      ));
    }
  }

  // Open a dialog to edit a product
  void _editProduct(Map<String, dynamic> product) {
    String productName = product['name'];
    String productPrice = product['price'].toString();
    String productStatus = product['status'] ?? 'Draft';

    showDialog(
      context: context,
      builder: (context) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 300),
          padding: MediaQuery.of(context).viewInsets,
          child: AlertDialog(
            title: const Text("Edit Product"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Product Name'),
                  controller: TextEditingController(text: productName),
                  onChanged: (value) => productName = value,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Product Price'),
                  controller: TextEditingController(text: productPrice),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => productPrice = value,
                ),
                DropdownButtonFormField<String>(
                  value: productStatus,
                  items: ['Published', 'Draft', 'Unpublished']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) => productStatus = value!,
                  decoration: const InputDecoration(labelText: 'Status'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (productName.isNotEmpty && productPrice.isNotEmpty) {
                    await _editProductInDatabase(
                      int.parse(product['id'].toString()),
                      productName,
                      productPrice,
                      productStatus,
                    );
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  }
                },
                child: const Text("Save"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancel"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 185, 34, 23),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/admin-dashboard'),
              child: Image.asset(
                'assets/images/logo_1.png',
                height: 80,
              ),
            ),
            Text(
              'PRODUCTS',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 4,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search here...',
                      hintStyle: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, color: Colors.black),
                      SizedBox(width: 5),
                      Text(
                        'ADD PRODUCTS',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Table Header with Proper Column Widths & Left Alignment
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 3, // Increase width for product names
                    child: Text(
                      'PRODUCTS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'PRICE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'STATUS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'ACTION',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3, // More space for details column
                    child: Text(
                      'DETAILS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _products.isEmpty
                  ? const Center(child: Text('No products found'))
                  : ListView.builder(
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3, // Match header width
                                  child: Text(
                                    product['name'],
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    product['price'],
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 4.0),
                                    decoration: BoxDecoration(
                                      color: product['status'] == 'Published'
                                          ? Colors.green.shade100
                                          : Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          product['status'] == 'Published'
                                              ? Icons.check_circle
                                              : Icons.warning,
                                          color:
                                              product['status'] == 'Published'
                                                  ? Colors.green
                                                  : Colors.red,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          product['status'].toUpperCase(),
                                          style: TextStyle(
                                            color:
                                                product['status'] == 'Published'
                                                    ? Colors.green
                                                    : Colors.red,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blue, size: 20),
                                        onPressed: () {
                                          _editProduct(product);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red, size: 20),
                                        onPressed: () {
                                          _confirmDeleteProduct(int.parse(
                                              product['id'].toString()));
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 3, // More space for details
                                  child: Text(
                                    product['details'] ?? '',
                                    textAlign:
                                        TextAlign.left, // Left align text
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
