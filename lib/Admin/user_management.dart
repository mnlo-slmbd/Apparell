// ignore_for_file: use_build_context_synchronously, avoid_print, no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class UserManagement extends StatefulWidget {
  const UserManagement({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UserManagementState createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  List<User> _users = [];
  List<User> _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final url = Uri.parse('http://localhost/Apparell_backend/get_users.php');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'] == 'success') {
          final List<dynamic> userList = jsonResponse['users'];
          setState(() {
            _users = userList.map((user) => User.fromJson(user)).toList();
            _filteredUsers = _users;
          });
        } else {
          print("Server returned error: ${jsonResponse['message']}");
        }
      } else {
        print("HTTP Error: ${response.statusCode}");
      }
    } catch (error) {
      print('Error fetching users: $error');
    }
  }

  Future<void> _deleteUser(User user) async {
    try {
      final url =
          Uri.parse('http://localhost/Apparell_backend/delete_user.php');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": user.email}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          setState(() {
            _users.remove(user);
            _filteredUsers = _users;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User ${user.name} deleted successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Failed to delete user: ${responseData['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete user: Server error')),
        );
      }
    } catch (error) {
      print('Error deleting user: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred while deleting the user')),
      );
    }
  }

  void _searchUser(String query) {
    setState(() {
      _filteredUsers = _users
          .where((user) =>
              user.name.toLowerCase().contains(query.toLowerCase()) ||
              user.position.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
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
              onTap: () {
                Navigator.pushNamed(context, '/admin-dashboard');
              },
              child: Image.asset('assets/images/logo_1.png', height: 70),
            ),
            Text(
              'User Management',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.white, // Body background color set to white
        child: Column(
          children: [
            _buildSearchAndAction(),
            const Divider(height: 0),
            _buildTableHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: _buildUserTable(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndAction() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Search Bar with Drop Shadow & Light Blue Icon
          Material(
            elevation: 8, // Stronger shadow for better visibility
            shadowColor: Colors.black38, // Darker shadow for more contrast
            borderRadius: BorderRadius.circular(12), // Rounded corners
            child: Container(
              width: 250,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _searchUser,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  hintText: 'Search a user...',
                  hintStyle:
                      GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(
                        0xFF64B5F6), // Light blue color (Material Blue 300)
                  ),
                  border: InputBorder.none, // Removes default border
                ),
                style: GoogleFonts.poppins(fontSize: 12),
              ),
            ),
          ),

          // Add User Button
          ElevatedButton(
            onPressed: () async {
              await Navigator.pushNamed(context, '/user-registration');
              _fetchUsers(); // Refresh users after adding a new user
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              '+ ADD USER',
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 1, child: _headerCell('')),
          Expanded(flex: 2, child: _headerCell('Name')),
          Expanded(flex: 2, child: _headerCell('Position')),
          Expanded(flex: 2, child: _headerCell('Store')),
          Expanded(flex: 3, child: _headerCell('Email')),
          Expanded(flex: 2, child: _headerCell('Phone')),
          Expanded(flex: 1, child: _headerCell('Edit')),
        ],
      ),
    );
  }

  Widget _headerCell(String title) {
    return Text(title,
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold));
  }

  Widget _buildUserTable() {
    return Column(
      children: _filteredUsers.map((user) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          decoration: BoxDecoration(
            border: user.isExpanded
                ? Border.all(color: Colors.blue, width: 1.0)
                : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Container(
                color:
                    user.isExpanded ? Colors.blue.shade50 : Colors.transparent,
                child: ListTile(
                  leading: Checkbox(
                    activeColor: Colors.black,
                    value: user.isExpanded,
                    onChanged: (bool? value) {
                      setState(() => user.isExpanded = value ?? false);
                    },
                  ),
                  title: Row(
                    children: [
                      Expanded(
                          flex: 2, child: Text(user.name, style: _textStyle())),
                      Expanded(
                          flex: 2,
                          child: Text(user.position, style: _textStyle())),
                      Expanded(
                          flex: 2,
                          child: Text(user.store, style: _textStyle())),
                      Expanded(
                          flex: 3,
                          child: Text(user.email, style: _textStyle())),
                      Expanded(
                          flex: 2,
                          child: Text(user.phone,
                              style: _textStyle(color: Colors.blue))),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _editUser(user),
                        icon: const Icon(Icons.edit, color: Colors.blue),
                      ),
                      IconButton(
                        onPressed: () => _deleteUser(user),
                        icon: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
              if (user.isExpanded) _buildUserDetails(user),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUserDetails(User user) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _infoColumn('Store Location', Icons.store, user.store),
          _infoColumn('Birthday', Icons.cake, user.birthday ?? 'N/A'),
          _infoColumn('Date Employed', Icons.calendar_today,
              user.dateEmployed ?? 'N/A'),
          _infoColumnWithPasswordToggle('Password', Icons.lock, user.password),
        ],
      ),
    );
  }

  void _editUser(User user) async {
    final updatedUser = await Navigator.pushNamed(
      context,
      '/edit-user', // Make sure this route exists in your app
      arguments: user, // Pass the user details as arguments
    );

    if (updatedUser != null && updatedUser is User) {
      setState(() {
        int index = _users.indexWhere((u) => u.email == updatedUser.email);
        if (index != -1) {
          _users[index] = updatedUser;
          _filteredUsers = _users;
        }
      });
    }
  }

  Widget _infoColumn(String title, IconData icon, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        Text(value, style: _textStyle()),
      ],
    );
  }

  Widget _infoColumnWithPasswordToggle(
      String title, IconData icon, String password) {
    bool _showPassword = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(title,
                    style: GoogleFonts.poppins(
                        fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              children: [
                Text(
                  _showPassword ? password : '*****',
                  style: _textStyle(),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                  child: Icon(
                    _showPassword ? Icons.visibility_off : Icons.visibility,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  TextStyle _textStyle({Color? color}) {
    return GoogleFonts.poppins(fontSize: 12, color: color ?? Colors.black);
  }
}

class User {
  final String name, position, store, email, phone, password;
  final String? birthday, dateEmployed;
  bool isExpanded;

  User({
    required this.name,
    required this.position,
    required this.store,
    required this.email,
    required this.phone,
    required this.password,
    this.birthday,
    this.dateEmployed,
    this.isExpanded = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      position: json['position'],
      store: json['store_name'],
      email: json['email'],
      phone: json['mobile'],
      password: json['password'],
      birthday: json['date_of_birth'],
      dateEmployed: json['date_employed'],
    );
  }
}
