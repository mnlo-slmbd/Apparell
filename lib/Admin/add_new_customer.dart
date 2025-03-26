import 'package:flutter/material.dart';

class AddNewCustomer extends StatefulWidget {
  const AddNewCustomer({super.key});

  @override
  State<AddNewCustomer> createState() => _AddNewCustomerState();
}

class _AddNewCustomerState extends State<AddNewCustomer> {
  final Map<String, bool> _checkboxStates = {};
  final List<Map<String, String>> _customerList = [];

  final List<String> provinces = ['Abra', 'Cebu', 'Davao', 'Manila'];
  final Map<String, List<String>> cities = {
    'Abra': ['Bangued', 'Boliney', 'Bucay'],
    'Cebu': ['Cebu City', 'Mandaue', 'Lapu-Lapu'],
    'Davao': ['Davao City', 'Panabo', 'Tagum'],
    'Manila': ['Manila', 'Makati', 'Quezon City'],
  };
  final Map<String, List<String>> barangays = {
    'Bangued': ['Zone 1', 'Zone 2', 'Zone 3'],
    'Cebu City': ['Barangay 1', 'Barangay 2', 'Barangay 3'],
    'Davao City': ['Barangay A', 'Barangay B', 'Barangay C'],
    'Manila': ['Barangay 100', 'Barangay 101', 'Barangay 102'],
  };

  bool _isFormVisible = false;
  String? _selectedProvince;
  String? _selectedCity;
  String? _selectedBarangay;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();

  void _saveCustomer() {
    setState(() {
      _customerList.add({
        'name': '${_firstNameController.text} ${_lastNameController.text}',
        'contact': _contactController.text,
        'email': _emailController.text,
        'province': _selectedProvince ?? '',
        'city': _selectedCity ?? '',
        'barangay': _selectedBarangay ?? '',
      });
      _checkboxStates[_customerList.last['name']!] = false;
      _isFormVisible = false;

      _firstNameController.clear();
      _lastNameController.clear();
      _contactController.clear();
      _emailController.clear();
      _selectedProvince = null;
      _selectedCity = null;
      _selectedBarangay = null;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer added successfully!')),
      );
    });
  }

  void _editCustomer(int index) {
    setState(() {
      final customer = _customerList[index];
      _firstNameController.text = customer['name']!.split(' ')[0];
      _lastNameController.text = customer['name']!.split(' ')[1];
      _contactController.text = customer['contact']!;
      _emailController.text = customer['email']!;
      _selectedProvince = customer['province'];
      _selectedCity = customer['city'];
      _selectedBarangay = customer['barangay'];
      _isFormVisible = true;

      _customerList.removeAt(index);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Editing customer details...')),
      );
    });
  }

  void _deleteCustomer(int index) {
    setState(() {
      _checkboxStates.remove(_customerList[index]['name']);
      _customerList.removeAt(index);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer deleted successfully!')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'CUSTOMERS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 185, 34, 23),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isFormVisible = !_isFormVisible;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
              ),
              child: const Text(
                'ADD CUSTOMER',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(Icons.people, color: Colors.grey[800], size: 20),
                        const SizedBox(width: 8.0),
                        const Text(
                          'CUSTOMERS',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _customerList.length,
                      itemBuilder: (context, index) {
                        final customer = _customerList[index];
                        return ListTile(
                          leading: Checkbox(
                            value: _checkboxStates[customer['name']],
                            onChanged: (bool? value) {
                              setState(() {
                                _checkboxStates[customer['name']!] = value!;
                              });
                            },
                            activeColor: Colors.black,
                          ),
                          title: Text(
                            customer['name']!,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                            ),
                          ),
                          subtitle: Text(
                            customer['contact']!,
                            style: const TextStyle(fontSize: 10),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.green, size: 16),
                                onPressed: () => _editCustomer(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red, size: 16),
                                onPressed: () => _deleteCustomer(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Form
          if (_isFormVisible)
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ADD CUSTOMER',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                              labelStyle: TextStyle(fontSize: 12),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: TextField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                              labelStyle: TextStyle(fontSize: 12),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _contactController,
                            decoration: const InputDecoration(
                              labelText: 'Contact No.',
                              labelStyle: TextStyle(fontSize: 12),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                              labelStyle: TextStyle(fontSize: 12),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedProvince,
                            items: provinces
                                .map((province) => DropdownMenuItem(
                                    value: province, child: Text(province)))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedProvince = value;
                                _selectedCity = null;
                                _selectedBarangay = null;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Province',
                              labelStyle: TextStyle(fontSize: 12),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedCity,
                            items: _selectedProvince == null
                                ? []
                                : cities[_selectedProvince]!
                                    .map((city) => DropdownMenuItem(
                                        value: city, child: Text(city)))
                                    .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCity = value;
                                _selectedBarangay = null;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'City',
                              labelStyle: TextStyle(fontSize: 12),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    DropdownButtonFormField<String>(
                      value: _selectedBarangay,
                      items: _selectedCity == null
                          ? []
                          : barangays[_selectedCity]!
                              .map((barangay) => DropdownMenuItem(
                                  value: barangay, child: Text(barangay)))
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBarangay = value;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Barangay',
                        labelStyle: TextStyle(fontSize: 12),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isFormVisible = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          child: const Text(
                            'CANCEL',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _saveCustomer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text(
                            'SAVE CUSTOMER',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
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
