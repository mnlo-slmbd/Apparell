// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class UserRegistration extends StatefulWidget {
  const UserRegistration({super.key});

  @override
  UserRegistrationState createState() => UserRegistrationState();
}

class UserRegistrationState extends State<UserRegistration> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _dateEmployedController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  bool _passwordVisible = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = pickedFile;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _registerUser() async {
    try {
      final url =
          Uri.parse('http://localhost/Apparell_backend/register_user.php');

      // Function to parse dates safely
      String? parseDate(String date) {
        try {
          return DateFormat('yyyy-MM-dd')
              .format(DateFormat('MMM/dd/yyyy').parse(date));
        } catch (_) {
          return null;
        }
      }

      // Safely parse dates
      final formattedDateOfBirth = _dateOfBirthController.text.isNotEmpty
          ? parseDate(_dateOfBirthController.text)
          : null;

      final formattedDateEmployed = _dateEmployedController.text.isNotEmpty
          ? parseDate(_dateEmployedController.text)
          : null;

      // Prepare JSON body
      final body = {
        "name": _nameController.text.trim(),
        "store_name": _storeNameController.text.trim(),
        "date_of_birth": formattedDateOfBirth,
        "province": _provinceController.text.trim(),
        "email": _emailController.text.trim(),
        "position": _positionController.text.trim(),
        "mobile": _mobileController.text.trim(),
        "date_employed": formattedDateEmployed,
        "city": _cityController.text.trim(),
        "password": _passwordController.text.trim(),
      };

      // Log the JSON body for debugging
      print("Sending JSON: ${jsonEncode(body)}");

      // Send the POST request
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body), // Encode body as JSON
      );

      // Log the raw response for debugging
      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      // Parse the JSON response
      final responseData = jsonDecode(response.body);

      // Handle the response based on status code and response content
      if (response.statusCode == 200 && responseData['status'] == 'success') {
        _showRegistrationSuccessDialog();
      } else if (response.statusCode == 400) {
        _showErrorDialog('Invalid input. Please check your details.');
      } else if (response.statusCode == 500) {
        _showErrorDialog('Server error. Please try again later.');
      } else {
        _showErrorDialog(responseData['message'] ??
            'Unexpected error: ${response.statusCode}');
      }
    } catch (error) {
      // Log the error and show an error dialog
      print('Error: $error');
      _showErrorDialog('An error occurred: $error');
    }
  }

  void _showRegistrationSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Registration Successful!'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 50,
              ),
              SizedBox(height: 10),
              Text(
                'You have successfully registered.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  InputDecoration _getInputDecoration(String labelText, IconData icon) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.black),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon, color: Colors.grey),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey, width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey, width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.all(16),
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
            Image.asset(
              'assets/images/logo_1.png',
              height: 60,
            ),
            Text(
              'User Registration',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor:
                            const Color.fromARGB(255, 237, 236, 236),
                        backgroundImage: _selectedImage != null
                            ? NetworkImage(_selectedImage!.path)
                                as ImageProvider
                            : null,
                        child: _selectedImage == null
                            ? Icon(
                                Icons.camera_alt,
                                size: 50,
                                color: Colors.grey[700],
                              )
                            : null,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Upload Photo',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: _getInputDecoration('Name', Icons.person),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _storeNameController.text.isNotEmpty
                              ? _storeNameController.text
                              : null,
                          items: [
                            'Zus Customs ( Main )',
                            'Lotus Naga',
                            'Parklane',
                            'Chosen Few Daet',
                            'Chosen Few Sipocot',
                            'Chosen Few Goa',
                            'Lotus Iriga',
                            'Chosen Few Iriga',
                            'Nabua Dry Goods',
                            'Chosen Few Legazpi',
                          ].map((store) {
                            return DropdownMenuItem<String>(
                              value: store,
                              child: Text(store,
                                  style: GoogleFonts.poppins(fontSize: 12)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _storeNameController.text = value!;
                            });
                          },
                          decoration: _getInputDecoration(
                              'Store Name', Icons.store), // ✅ Store Name label
                          dropdownColor: Colors
                              .grey.shade100, // ✅ Dropdown background color
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a store';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _dateOfBirthController,
                          decoration: _getInputDecoration(
                              'Date of Birth', Icons.calendar_today),
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _dateOfBirthController.text =
                                    DateFormat('MMM/dd/yyyy')
                                        .format(pickedDate);
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _provinceController,
                          decoration:
                              _getInputDecoration('Province', Icons.map),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your province';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: _getInputDecoration('Email', Icons.email),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _positionController.text.isNotEmpty
                              ? _positionController.text
                              : null,
                          items: [
                            'Admin',
                            'Store Manager',
                            'Graphic Artist',
                            'Rename Staff',
                            'Warehouse Staff',
                          ].map((role) {
                            return DropdownMenuItem<String>(
                              value: role,
                              child: Text(role,
                                  style: GoogleFonts.poppins(fontSize: 12)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _positionController.text = value!;
                            });
                          },
                          decoration: _getInputDecoration(
                              'Position', Icons.work), // ✅ Label and icon
                          dropdownColor: Colors.grey
                              .shade100, // ✅ Background color of dropdown menu
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a position';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _mobileController,
                          decoration:
                              _getInputDecoration('Mobile', Icons.phone),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _dateEmployedController,
                          decoration: _getInputDecoration(
                              'Date Employed', Icons.calendar_today),
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _dateEmployedController.text =
                                    DateFormat('MMM/dd/yyyy')
                                        .format(pickedDate);
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _cityController,
                          decoration:
                              _getInputDecoration('City', Icons.location_city),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your city';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.black),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon:
                                const Icon(Icons.lock, color: Colors.grey),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          obscureText: !_passwordVisible,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: _registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Register Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
