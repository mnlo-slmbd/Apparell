// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logistic_management_system/PartnerStore/store_expenses.dart';
import 'package:logistic_management_system/PartnerStore/store_sales.dart';

class StoreReports extends StatefulWidget {
  final String storeName;
  const StoreReports({super.key, required this.storeName});

  @override
  _StoreReportsState createState() => _StoreReportsState();
}

class _StoreReportsState extends State<StoreReports> {
  bool _isHoveredSales = false;
  bool _isHoveredExpenses = false;

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
            Image.asset('assets/images/logo_1.png', height: 60),
            Text(
              widget.storeName, // ✅ Display Store Name in AppBar
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey.shade200],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildReportCard(
                    context,
                    'Sales',
                    'assets/images/sales_icon.png',
                    'View and track all sales transactions and reports.',
                    _isHoveredSales,
                    (hovered) => setState(() => _isHoveredSales = hovered),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              StoreSales(storeName: widget.storeName),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  _buildReportCard(
                    context,
                    'Expenses',
                    'assets/images/expenses_icon.png',
                    'Log and monitor business expenses.',
                    _isHoveredExpenses,
                    (hovered) => setState(() => _isHoveredExpenses = hovered),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              StoreExpenses(storeName: widget.storeName),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context,
    String title,
    String imagePath,
    String description,
    bool isHovered,
    ValueChanged<bool> onHover, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        onEnter: (_) => onHover(true),
        onExit: (_) => onHover(false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 280,
          height: 350,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isHovered ? Colors.blue.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isHovered
                    ? Colors.blueAccent.withOpacity(0.6)
                    : Colors.grey.withOpacity(0.3),
                blurRadius: isHovered ? 15 : 10,
                spreadRadius: isHovered ? 5 : 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                height: 80,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isHovered ? Colors.blue.shade700 : Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
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
