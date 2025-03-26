// ignore_for_file: unused_local_variable, unnecessary_null_comparison, duplicate_ignore, library_private_types_in_public_api, use_build_context_synchronously, use_super_parameters, avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<void> downloadAttachmentWeb(String url) async {
  html.window.open(url, '_blank');
}

class TaskAssignPage extends StatefulWidget {
  const TaskAssignPage({super.key});

  @override
  _TaskAssignPageState createState() => _TaskAssignPageState();
}

class _TaskAssignPageState extends State<TaskAssignPage> {
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> filteredOrders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    const String apiUrl =
        "http://localhost/apparell/Apparell_backend/get_order.php";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          orders = jsonResponse.map((order) {
            String details = "No Date";
            if (order["details"] != null &&
                order["details"] is String &&
                order["details"] !=
                    "[{description: null, qty: 0, unitPrice: 0, total: 0}]") {
              details = order["details"];
            }

            return {
              "orderId": order["orderId"]?.toString() ?? "",
              "teamName": order["teamName"]?.toString() ?? "",
              "deliveryDate": order["deliveryDate"]?.toString() ?? "",
              "branch": order["branch"]?.toString() ?? "",
              "category": order["category"]?.toString() ?? "",
              "details": details,
              "items": order["items"] ?? [],
              "selectedAssignee":
                  order["assigned_to"]?.toString(), // Allow null
            };
          }).toList();
          filteredOrders = orders;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load orders");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching orders: $e")),
      );
    }
  }

  Future<void> assignTask(String orderId, String assignee, int index) async {
    const String apiUrl =
        "http://localhost/apparell/Apparell_backend/assign_order.php";
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"order_id": orderId, "assignee": assignee}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse["status"] == "success") {
          final currentDateTime =
              DateFormat('MMMM dd, yyyy HH:mm:ss').format(DateTime.now());

          setState(() {
            orders[index]["selectedAssignee"] = assignee;
            filteredOrders[index]["selectedAssignee"] = assignee;
            orders[index]["details"] = currentDateTime;
            filteredOrders[index]["details"] = currentDateTime;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Order $orderId assigned to $assignee")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${jsonResponse['message']}")),
          );
        }
      } else {
        throw Exception("Failed to assign task");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error assigning task: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteOrder(String orderId, int index) async {
    const String apiUrl =
        "http://localhost/apparell/Apparell_backend/delete_order.php";

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"order_id": orderId}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse["status"] == "success") {
          setState(() {
            orders.removeAt(index);
            filteredOrders.removeAt(index);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Order $orderId deleted successfully")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: ${jsonResponse['message']}")),
          );
        }
      } else {
        throw Exception("Failed to delete order");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting order: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  //Filter Orders
  void filterOrders(String query) {
    setState(() {
      filteredOrders = orders
          .where((order) =>
              order['orderId'].toLowerCase().contains(query.toLowerCase()) ||
              order['teamName'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 185, 34, 23),
        elevation: 0, // No shadow for a clean look
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(context, '/admin-dashboard'); // Navigate back
          },
        ),
        title: Align(
          alignment: Alignment.centerRight, // Moves the title to the right
          child: Text(
            'Task Assign',
            style: GoogleFonts.poppins(
              //
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: 280, // Slightly wider for better usability
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 3,
                              blurRadius: 10,
                              offset: const Offset(0, 3), // Drop shadow effect
                            ),
                          ],
                        ),
                        child: TextField(
                          onChanged:
                              filterOrders, // Calls function when text changes
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search,
                                color: Colors.grey, size: 22), // Bigger icon
                            hintText: 'Search for an order...',
                            filled: true,
                            fillColor: Colors.white,
                            border: InputBorder.none, // No border
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 14.0, horizontal: 16.0),
                            hintStyle: GoogleFonts.poppins(
                                color: Colors.grey,
                                fontSize: 15), // Softer hint text
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none, // Remove border
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none, // Remove border
                            ),
                          ),
                          style: GoogleFonts.poppins(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'All Orders (${filteredOrders.length})',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 156, 207, 241),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Order ID',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Team Name',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Delivery Date',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Branch',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Category',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Assign To',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Details',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Actions',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = filteredOrders[index];
                        return Column(
                          children: [
                            OrderRow(
                              order: order,
                              onViewDetails: () => fetchOrderDetailsAndNavigate(
                                  order['orderId']),
                              onAssign: (assignee) =>
                                  assignTask(order['orderId'], assignee, index),
                              onDelete: () =>
                                  deleteOrder(order['orderId'], index),
                            ),
                            const Divider(),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void fetchOrderDetailsAndNavigate(String orderId) async {
    const String apiUrl =
        "http://localhost/apparell/Apparell_backend/get_order_details.php";

    try {
      final response = await http.get(Uri.parse('$apiUrl?order_id=$orderId'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == 'success') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  OrderDetailsPage(order: jsonResponse['data']),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${jsonResponse['message']}')),
          );
        }
      } else {
        throw Exception("Failed to fetch order details");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching order details: $e')),
      );
    }
  }
}

//Order Row Start
class OrderRow extends StatefulWidget {
  final Map<String, dynamic> order;
  final VoidCallback onViewDetails;
  final Function(String assignee) onAssign;
  final VoidCallback onDelete;

  const OrderRow({
    Key? key,
    required this.order,
    required this.onViewDetails,
    required this.onAssign,
    required this.onDelete,
  }) : super(key: key);

  @override
  _OrderRowState createState() => _OrderRowState();
}

class _OrderRowState extends State<OrderRow> {
  bool isOrderIdHovered = false; // Track hover for Order ID
  bool isAssignButtonHovered = false; // Track hover for Assign To button
  String? selectedAssignee;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isSmallScreen = constraints.maxWidth < 600;

        return Row(
          children: [
            // Order ID - Only Order ID changes color on hover
            Expanded(
              flex: 1,
              child: MouseRegion(
                onEnter: (_) => setState(() => isOrderIdHovered = true),
                onExit: (_) => setState(() => isOrderIdHovered = false),
                child: GestureDetector(
                  onTap: widget.onViewDetails,
                  child: Text(
                    widget.order['orderId'],
                    style: GoogleFonts.poppins(
                      color: isOrderIdHovered ? Colors.blue[800] : Colors.blue,
                      fontWeight: FontWeight.w600, // Slightly bold
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            // Team Name
            Expanded(
              flex: 2,
              child: Text(
                widget.order['teamName'],
                textAlign: TextAlign.center,
              ),
            ),

            // Delivery Date
            Expanded(
              flex: 2,
              child: Text(
                widget.order['deliveryDate'],
                textAlign: TextAlign.center,
              ),
            ),

            // Branch
            Expanded(
              flex: 2,
              child: Text(
                widget.order['branch'],
                textAlign: TextAlign.center,
              ),
            ),

            // Category (No Bold)
            Expanded(
              flex: 1,
              child: Text(
                widget.order['category'],
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: widget.order['category'] == 'Rush Order'
                      ? Colors.red
                      : Colors.black,
                ),
              ),
            ),

            // Assign To - Button Style with Separate Hover Effect
            Expanded(
              flex: 2,
              child: Center(
                child: MouseRegion(
                  onEnter: (_) => setState(() => isAssignButtonHovered = true),
                  onExit: (_) => setState(() => isAssignButtonHovered = false),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAssignButtonHovered
                          ? Colors.blue[700]
                          : Colors.white,
                      elevation: isAssignButtonHovered ? 4 : 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      side: const BorderSide(color: Colors.grey, width: 1),
                      fixedSize: const Size(96, 40), // Fixed button size
                    ),
                    onPressed: () async {
                      String? selected = await showDialog<String>(
                        context: context,
                        builder: (context) => SimpleDialog(
                          title: const Text("Select Assignee"),
                          children: [
                            SimpleDialogOption(
                              onPressed: () =>
                                  Navigator.pop(context, 'Sherwin'),
                              child: const Center(child: Text('Sherwin')),
                            ),
                            SimpleDialogOption(
                              onPressed: () => Navigator.pop(context, 'Jron'),
                              child: const Center(child: Text('Jron')),
                            ),
                            SimpleDialogOption(
                              onPressed: () => Navigator.pop(
                                  context, 'Skip'), // Now just "Skip"
                              child: const Center(child: Text('Skip')),
                            ),
                          ],
                        ),
                      );
                      if (selected != null) {
                        setState(() {
                          widget.order['selectedAssignee'] =
                              selected; // Update order list
                          selectedAssignee = selected; // Update button label
                        });
                        widget.onAssign(selected);
                      }
                    },
                    child: Text(
                      selectedAssignee ??
                          widget.order['selectedAssignee'] ??
                          "Select",
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 12 : 14,
                        color:
                            isAssignButtonHovered ? Colors.white : Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),

            // Details
            Expanded(
              flex: 2,
              child: Text(
                widget.order['details'] ?? 'No Details',
                style: GoogleFonts.poppins(
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Delete Button
            Expanded(
              flex: 1,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: widget.onDelete,
              ),
            ),
          ],
        );
      },
    );
  }
}

//Order Row End

class OrderDetailsPage extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailsPage({Key? key, required this.order}) : super(key: key);

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  List<dynamic> attachments = [];

  @override
  void initState() {
    super.initState();
    fetchAttachments(widget.order['order']['order_id']);
  }

  Future<void> fetchAttachments(String orderId) async {
    // ignore: unnecessary_null_comparison
    if (orderId == null || orderId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Order ID is required.')),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost/apparell/Apparell_backend/fetch_attachments.php?order_id=$orderId'),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'] == 'success') {
          setState(() {
            attachments = jsonResponse['attachments'];
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${jsonResponse['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch attachments.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching attachments: $e')),
      );
    }
  }

  Future<void> downloadAndSaveFile(String url, String fileName) async {
    if (kIsWeb) {
      // For web: Use HTML to download the file
      try {
        final anchor = html.AnchorElement(href: url)
          ..target = '_blank'
          ..download = fileName
          ..click();
        print('File downloaded: $fileName');
      } catch (e) {
        print('Error downloading file: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading file: $e')),
        );
      }
    } else {
      // For mobile: Save the file locally
      try {
        // Get the application's documents directory
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName';

        // Fetch the file from the URL
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          // Save the file to the local directory
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          print('File saved to $filePath');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File downloaded to: $filePath')),
          );
        } else {
          print('Failed to download file: ${response.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to download file.')),
          );
        }
      } catch (e) {
        print('Error downloading file: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading file: $e')),
        );
      }
    }
  }

  Future<void> uploadAttachment(BuildContext context, String orderId) async {
    if (orderId == null || orderId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Order ID is required.')),
      );
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf'],
    );

    if (result != null) {
      PlatformFile pickedFile = result.files.first;
      print('Picked file: ${pickedFile.name}'); // Debugging

      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(
              'http://localhost/apparell/Apparell_backend/upload_attachment.php'),
        );

        request.fields['order_id'] = orderId; // Set order_id
        print('Sending order_id: $orderId'); // Debugging

        if (pickedFile.bytes != null) {
          request.files.add(http.MultipartFile.fromBytes(
            'attachment',
            pickedFile.bytes!,
            filename: pickedFile.name,
          ));
        } else if (pickedFile.path != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'attachment',
            pickedFile.path!,
          ));
        } else {
          throw Exception("File selection failed.");
        }

        var response = await request.send();

        if (response.statusCode == 200) {
          final respStr = await response.stream.bytesToString();
          final jsonResponse = jsonDecode(respStr);

          if (jsonResponse['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Attachment uploaded successfully!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${jsonResponse['message']}')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload attachment.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading file: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderDetails = widget.order['order'] ?? {};
    final items = widget.order['items'] ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 185, 34, 23),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.white), // Back Arrow in White
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Align(
          alignment: Alignment.centerRight, // Move title to the right
          child: Text(
            'Order Details',
            style: GoogleFonts.poppins(
              color: Colors.white, // Set to white
              fontSize: 18,
              fontWeight: FontWeight.bold, // Make bold
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionHeader('Order Summary'),
                buildInfoRow('Order ID:', orderDetails['order_id'] ?? 'N/A'),
                buildInfoRow(
                    'Date Order:', orderDetails['date_order'] ?? 'N/A'),
                buildInfoRow('Store:', orderDetails['store'] ?? 'N/A'),
                const SizedBox(height: 20),
                buildSectionHeader("Customer Information"),
                buildInfoRow(
                    'Customer Name:', orderDetails['customer_name'] ?? 'N/A'),
                buildInfoRow(
                    'Contact:', orderDetails['contact_number'] ?? 'N/A'),
                buildInfoRow('Address:', orderDetails['address'] ?? 'N/A'),
                buildInfoRow('Email Address:', orderDetails['email'] ?? 'N/A'),
                const SizedBox(height: 20),
                buildSectionHeader('Team Information'),
                buildInfoRow('Team Name:', orderDetails['team_name'] ?? 'N/A'),
                buildInfoRow(
                    'Delivery Date:', orderDetails['delivery_date'] ?? 'N/A'),
                const SizedBox(height: 20),
                buildSectionHeader('Order Items'),
                Table(
                  border: TableBorder.all(color: Colors.black54),
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(5),
                    2: FlexColumnWidth(2),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey.shade300),
                      children: [
                        buildTableHeader('ITEM'),
                        buildTableHeader('DESCRIPTION'),
                        buildTableHeader('QTY'),
                      ],
                    ),
                    ...items.map((item) {
                      return TableRow(
                        children: [
                          buildTableCell(item['description'] ?? 'N/A',
                              bold: true),
                          buildTableCell(item['description'] ?? 'N/A'),
                          buildTableCell(item['qty'].toString()),
                        ],
                      );
                    }).toList(),
                  ],
                ),
                const SizedBox(height: 20),
                buildSectionHeader('Payment Details'),
                buildInfoRow('Total Sale:',
                    orderDetails['total_sale']?.toString() ?? 'Php0.00'),
                buildInfoRow('Mode of Payment:', orderDetails['mop'] ?? 'N/A'),
                buildInfoRow('Downpayment:',
                    orderDetails['downpayment']?.toString() ?? 'Php0.00'),
                buildInfoRow('Balance:',
                    orderDetails['balance']?.toString() ?? 'Php0.00'),
                const SizedBox(height: 20),
                buildSectionHeader('Attachments'),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.red, // Adjust color to match your system
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                    ),
                  ),
                  onPressed: () =>
                      uploadAttachment(context, orderDetails['order_id'] ?? ''),
                  icon: const Icon(
                    Icons.cloud_upload,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Upload Attachment',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                attachments.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: attachments.length,
                        itemBuilder: (context, index) {
                          final attachment = attachments[index];
                          return ListTile(
                            leading: const Icon(Icons.attachment),
                            title: Text(attachment['file_name']),
                            subtitle: Text(
                                'Uploaded on: ${attachment['uploaded_at']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.download),
                              onPressed: () {
                                final url =
                                    'http://localhost/Apparell/Apparell_backend/${attachment['attachment_path']}';
                                final fileName = attachment['file_name'] ??
                                    'downloaded_file';
                                downloadAndSaveFile(url, fileName);
                              },
                            ),
                          );
                        },
                      )
                    : const Text('No attachments available.'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
    );
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(label,
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget buildTableHeader(String label) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildTableCell(String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal),
      ),
    );
  }
}
