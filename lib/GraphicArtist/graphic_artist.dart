// ignore_for_file: unused_local_variable, library_private_types_in_public_api, use_build_context_synchronously, avoid_print, unnecessary_to_list_in_spreads

import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class GraphicArtistTask extends StatefulWidget {
  final String assignee;

  const GraphicArtistTask({super.key, required this.assignee});

  @override
  _GraphicArtistTaskState createState() => _GraphicArtistTaskState();
}

class _GraphicArtistTaskState extends State<GraphicArtistTask> {
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterTasks);
    fetchAssignedTasks(); // Now without list
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchAssignedTasks() async {
    final String apiUrl =
        "http://localhost/Apparell_backend/get_assigned_tasks.php?assignees=${widget.assignee}";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          setState(() {
            _tasks = (jsonResponse['data'] as List).map((task) {
              return Task(
                teamName: task['teamName'] ?? 'N/A',
                orderID: task['orderId'] ?? 'N/A',
                orderType: task['orderType'] ?? 'N/A',
                quantity: task['quantity']?.toString() ?? 'N/A',
                itemType: task['itemType'] ?? 'N/A',
                branch: task['branch'] ?? 'N/A',
                dateOrder: DateTime.parse(task['dateOrder']),
                dueDate: DateTime.parse(task['dueDate']),
                status: task['status'] ?? 'N/A',
                customerName: task['customerName'],
                phoneNumber: task['phoneNumber'],
                emailAddress: task['emailAddress'],
              );
            }).toList();
            _filteredTasks = _tasks;
            isLoading = false;
          });
        } else {
          throw Exception(jsonResponse['message']);
        }
      } else {
        throw Exception("Failed to load tasks.");
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching tasks: $e")),
      );
    }
  }

  Future<void> fetchOrderDetailsAndNavigate(String orderID) async {
    const String apiUrl =
        "http://localhost/Apparell_backend/get_order_details.php";

    try {
      final response = await http.get(Uri.parse('$apiUrl?order_id=$orderID'));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // Debug print the response
        print(jsonResponse);

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

  void _filterTasks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTasks = _tasks.where((task) {
        return task.teamName.toLowerCase().contains(query) ||
            task.orderID.toLowerCase().contains(query) ||
            task.orderType.toLowerCase().contains(query) ||
            task.itemType.toLowerCase().contains(query) ||
            task.branch.toLowerCase().contains(query) ||
            task.status.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildSearchBar(),
                  const SizedBox(height: 20),
                  _buildTableHeader(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = _filteredTasks[index];
                        return _buildTaskRow(task);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 185, 34, 23),
      elevation: 0,
      titleSpacing: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'My Task',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Text(
                widget.assignee,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login_page',
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: Text(
                  'Logout',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 240,
        height: 35,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.black),
          decoration: InputDecoration(
            hintText: 'Search here...',
            hintStyle:
                GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
            prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 16),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      color: Colors.grey.shade200,
      child: Row(
        children: [
          _headerCell('Team Name'),
          _headerCell('OrderID'),
          _headerCell('Order Type'),
          _headerCell('Qty'),
          _headerCell('Item Type'),
          _headerCell('Branch'),
          _headerCell('Date Order'),
          _headerCell('Due Date'),
          _headerCell('Status'),
        ],
      ),
    );
  }

  Widget _headerCell(String title) {
    return Expanded(
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: Colors.black87,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildTaskRow(Task task) {
    final dateFormat = DateFormat('MMM.dd, yyyy');
    return Column(
      children: [
        InkWell(
          onTap: () => fetchOrderDetailsAndNavigate(task.orderID),
          child: Container(
            color: task.isExpanded ? Colors.blue.shade50 : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              children: [
                _tableCell(task.teamName),
                _tableCell(
                  task.orderID,
                  isBold: true,
                  textColor: Colors.blue,
                ),
                _tableCell(
                  task.orderType,
                  textColor: task.orderType.toLowerCase() == 'rush order'
                      ? Colors.red
                      : Colors.black87,
                ),
                _tableCell(task.quantity),
                _tableCell(task.itemType),
                _tableCell(task.branch),
                _tableCell(dateFormat.format(task.dateOrder)),
                _tableCell(dateFormat.format(task.dueDate)),
                Expanded(
                  child: Text(
                    task.status,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color:
                          task.status == 'Active' ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(
            height: 1, color: Colors.grey), // 👈 Underline after each row
      ],
    );
  }

  Widget _tableCell(String text,
      {bool isBold = false, Color textColor = Colors.black87}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class Task {
  String teamName, orderID, orderType, quantity, itemType, branch, status;
  DateTime dateOrder, dueDate;
  String? customerName, phoneNumber, emailAddress;
  bool isExpanded;

  Task({
    required this.teamName,
    required this.orderID,
    required this.orderType,
    required this.quantity,
    required this.itemType,
    required this.branch,
    required this.dateOrder,
    required this.dueDate,
    required this.status,
    this.customerName,
    this.phoneNumber,
    this.emailAddress,
    this.isExpanded = false,
  });
}

class OrderDetailsPage extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailsPage({super.key, required this.order});

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

  Future<void> _deleteAttachment(String attachmentId) async {
    const String apiUrl =
        "http://localhost/Apparell_backend/delete_attachment.php";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"attachment_id": attachmentId}),
      );

      final jsonResponse = json.decode(response.body);

      if (jsonResponse["status"] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Attachment deleted successfully")),
        );
        fetchAttachments(
            widget.order['order']['order_id']); // Refresh attachment list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${jsonResponse['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting attachment: $e")),
      );
    }
  }

  void _confirmDeleteAttachment(BuildContext context, String attachmentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Attachment"),
          content:
              const Text("Are you sure you want to delete this attachment?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                await _deleteAttachment(attachmentId);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child:
                  const Text("Delete", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchAttachments(String orderId) async {
    // Change const to final
    final String apiUrl =
        "http://localhost/Apparell_backend/fetch_attachments.php?order_id=$orderId";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          setState(() {
            attachments = jsonResponse['attachments'];
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Error fetching attachments: ${jsonResponse['message']}')),
          );
        }
      } else {
        throw Exception('Failed to fetch attachments');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching attachments: $e')),
      );
    }
  }

  Future<void> sendToTestPrint(BuildContext context, String? orderId) async {
    const String apiUrl =
        "http://localhost/Apparell_backend/send_to_testprint.php";

    if (orderId == null || orderId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order ID is missing or invalid.')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({'order_id': orderId}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Order sent to Test Print successfully')),
          );
          Navigator.pop(context); // Go back to the previous page
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${jsonResponse['message']}')),
          );
        }
      } else {
        throw Exception("Failed to send order to Test Print");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending order to Test Print: $e')),
      );
    }
  }

  Future<void> uploadAttachment(String orderId) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final file = result.files.first;

      try {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('http://localhost/Apparell_backend/upload_attachment.php'),
        );
        request.fields['order_id'] = orderId;
        if (kIsWeb) {
          request.files.add(http.MultipartFile.fromBytes(
            'attachment',
            file.bytes!,
            filename: file.name,
          ));
        } else {
          request.files.add(await http.MultipartFile.fromPath(
            'attachment',
            file.path!,
          ));
        }

        final response = await request.send();
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Attachment uploaded successfully')),
          );
          fetchAttachments(orderId); // Refresh attachments
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload attachment')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading attachment: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected')),
      );
    }
  }

  Future<void> downloadAndSaveFile(String url, String fileName) async {
    if (kIsWeb) {
      try {
        final anchor = html.AnchorElement(href: url)
          ..target = '_blank'
          ..download = fileName
          ..click();
        print('File downloaded: $fileName');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading file: $e')),
        );
      }
    } else {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName';

        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File downloaded to: $filePath')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to download file.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading file: $e')),
        );
      }
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
              color: Colors.white), // White back button
          onPressed: () {
            Navigator.of(context).pop(); // Go back when clicked
          },
        ),
        title: Text(
          'Order Details',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold, // Make text bold
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Order Summary'),
              _buildInfoRow('Order ID:', orderDetails['order_id'] ?? 'N/A'),
              _buildInfoRow(
                  'Customer Name:', orderDetails['customer_name'] ?? 'N/A'),
              _buildInfoRow(
                  'Contact Number:', orderDetails['contact_number'] ?? 'N/A'),
              _buildInfoRow('Address:', orderDetails['address'] ?? 'N/A'),
              _buildInfoRow('Email:', orderDetails['email'] ?? 'N/A'),
              const SizedBox(height: 20),
              _buildSectionHeader('Order Items'),
              const SizedBox(height: 10),
              _buildItemsTable(items),
              const SizedBox(height: 20),
              _buildSectionHeader('Attachments'),
              ElevatedButton.icon(
                onPressed: () => uploadAttachment(orderDetails['order_id']),
                icon: const Icon(Icons.upload_file,
                    color: Colors.white), // Add upload icon
                label: Text(
                  'Upload Attachment',
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                      255, 139, 139, 139), // Change button color
                  foregroundColor: Colors.white, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded edges
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 20), // Add padding
                  elevation: 3, // Add shadow effect
                ),
              ),
              attachments.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: attachments.length,
                      itemBuilder: (context, index) {
                        final attachment = attachments[index];
                        return ListTile(
                          title: Text(attachment['file_name']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.download,
                                    color: Colors.blue),
                                onPressed: () {
                                  final url =
                                      'http://localhost/Apparell_backend/${attachment['attachment_path']}';
                                  final fileName = attachment['file_name'] ??
                                      'downloaded_file';
                                  downloadAndSaveFile(url, fileName);
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  if (attachment['id'] != null) {
                                    _confirmDeleteAttachment(
                                        context, attachment['id'].toString());
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Cannot delete: attachment ID not found')),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : const Text('No attachments available.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final confirm = await _showConfirmationDialog(context);
                  if (confirm) {
                    sendToTestPrint(
                        context, orderDetails['order_id'] ?? 'Unknown ID');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize:
                      const Size(double.infinity, 40), // Full-width button
                ),
                child: const Text(
                  'Send to TestPrint',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 14, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTable(List<dynamic> items) {
    if (items.isEmpty) {
      return const Text(
        'No items available.',
        style: TextStyle(fontSize: 14, color: Colors.black54),
      );
    }
    return Table(
      border: TableBorder.all(color: Colors.grey),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(5),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(color: Colors.grey),
          children: [
            _buildTableHeader('ITEM'),
            _buildTableHeader('DESCRIPTION'),
            _buildTableHeader('QTY'),
            _buildTableHeader('TOTAL'),
          ],
        ),
        ...items.map((item) {
          return TableRow(
            children: [
              _buildTableCell('Uniform'),
              _buildTableCell(item['description'] ?? 'N/A'),
              _buildTableCell(item['qty']?.toString() ?? '0'),
              _buildTableCell('Php ${item['total']?.toString() ?? '0.00'}'),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTableHeader(String label) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTableCell(String value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Action'),
              content: const Text(
                  'Are you sure you want to send this order to TestPrint?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
