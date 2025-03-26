import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logistic_management_system/PartnerStore/order_monitoring.dart';
import 'package:logistic_management_system/PartnerStore/sample_purchase.dart';
import 'package:logistic_management_system/PartnerStore/store_reports.dart';

class OrderPage extends StatefulWidget {
  final String storeName;

  const OrderPage({
    super.key,
    required this.storeName, // ✅ <-- this is the fix!
  });

  @override
  // ignore: library_private_types_in_public_api
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  bool _isHoveredNewOrder = false;
  bool _isHoveredAdditionalOrder = false;
  String _activeTab = 'Create Order';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 185, 34, 23),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo_1.png',
              height: 60,
            ),
            const SizedBox(width: 10),
            Text(
              ' ${widget.storeName}', // ✅ Store name displayed here
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/login_page');
            },
          ),
        ],
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
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  color: Colors.transparent,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildTab(context, 'Create Order'),
                        _buildTab(context, 'Reports'),
                        _buildTab(context, 'Monitoring'),
                      ],
                    ),
                  ),
                ),
                Divider(height: 1, color: Colors.grey.shade300),
                const SizedBox(height: 20),
                Text(
                  'Choose Options',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildOptionCard(
                        context,
                        'New Order',
                        'assets/images/new_order_icon.png',
                        'Tap to place a new order. Use for initial purchases or new requests.',
                        _isHoveredNewOrder,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PurchaseOrderForms(
                                  storeName: widget.storeName),
                            ),
                          );
                        },
                        (hovered) {
                          setState(() {
                            _isHoveredNewOrder = hovered;
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildOptionCard(
                        context,
                        'Additional Order',
                        'assets/images/additional_order_icon.png',
                        'Select this option to add more items to an existing order or to update a current order.',
                        _isHoveredAdditionalOrder,
                        () {
                          Navigator.pushNamed(context, '/additional-order');
                        },
                        (hovered) {
                          setState(() {
                            _isHoveredAdditionalOrder = hovered;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, String label) {
    bool isActive = _activeTab == label;

    return MouseRegion(
      onEnter: (_) => setState(() {}),
      onExit: (_) => setState(() {}),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeTab = label;
          });

          if (label == 'Reports') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StoreReports(storeName: widget.storeName),
              ),
            );
          } else if (label == 'Monitoring') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    StoreMonitoring(storeName: widget.storeName),
              ),
            );
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          width: 140, // Increased width for longer text
          height: 50, // Slightly increased height for better spacing
          decoration: BoxDecoration(
            color: isActive ? Colors.blue.shade100 : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: isActive
                    ? Colors.blueAccent.withOpacity(0.5)
                    : Colors.grey.withOpacity(0.2),
                blurRadius: isActive ? 10 : 6,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isActive ? Colors.blue : Colors.transparent,
              width: isActive ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: isActive ? Colors.blue.shade700 : Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    String title,
    String imagePath,
    String description,
    bool isHovered,
    VoidCallback onPressed,
    ValueChanged<bool> onHover,
  ) {
    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 280,
          height: 330,
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
                height: 120,
                width: 120,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isHovered ? Colors.blue.shade700 : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
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
