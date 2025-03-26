import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show Uint8List, rootBundle;

class CustomersCopy extends StatelessWidget {
  final GlobalKey _printKey = GlobalKey();

  CustomersCopy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 17, 0),
        title: const Text(
          'PURCHASE ORDER FORM',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: RepaintBoundary(
          key: _printKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomerReceiptBox(),
              const SizedBox(height: 20),
              _buildMaterialAvailabilityCheck(),
              const SizedBox(height: 40),
              _buildBottomButtons(),
              const SizedBox(height: 20),
              _buildAttachments(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerReceiptBox() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/logo_1.png',
                  height: 180,
                  width: 180,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'CUSTOMER RECEIPT',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          'CBD II Triangulo, Naga City, Camarines Sur\nzuscustoms2021@gmail.com\n0998 226 1132 | 0945 533 1129',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCheckboxWithLabel('Regular Order', true),
                _buildCheckboxWithLabel('Rush Order', false),
                _buildCheckboxWithLabel('Big Order', false),
                _buildCheckboxWithLabel('Philgeps Order', false),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInlineTextDisplay(
                          'DATE ORDER', 'September 27, 2024'),
                      _buildInlineTextDisplay('STORE', 'Chosen Few Malolos'),
                      const SizedBox(height: 10),
                      Text(
                        "CUSTOMER'S INFORMATION",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildInlineTextDisplay('Customer Name', 'Alice Guo'),
                      _buildInlineTextDisplay('Contact', '+63927 865 5333'),
                      _buildInlineTextDisplay('Address', 'Naga City'),
                      _buildInlineTextDisplay(
                          'Email Address', 'AliceGuo@gmail.com'),
                      _buildInlineTextDisplay('Order ID', '0001'),
                      const SizedBox(height: 10),
                      _buildInlineTextDisplay('Team Name', 'Team Phoenix'),
                      _buildInlineTextDisplay(
                          'Delivery Date', 'October 17, 2024'),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CLASSIFICATION',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildClassificationOption('New Order', false),
                        _buildClassificationOption('Additional', true),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildOrderDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ORDER DETAILS',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 10),
        Table(
          border: TableBorder.all(color: Colors.grey[300]!),
          columnWidths: const {
            0: FlexColumnWidth(1.5),
            1: FlexColumnWidth(3),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(1),
            4: FlexColumnWidth(1),
            5: FlexColumnWidth(1.5),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: Colors.grey[300],
              ),
              children: [
                _buildTableHeader('ITEM'),
                _buildTableHeader('DESCRIPTION'),
                _buildTableHeader('NOTES'),
                _buildTableHeader('QTY'),
                _buildTableHeader('ORIG PRICE'),
                _buildTableHeader('TOTAL'),
              ],
            ),
            _buildOrderDetailRow('Uniform', 'Jersey Set', 'No notes', '12',
                '500.00', '7,800.00'),
            _buildOrderDetailRow(
                'Uniform', 'T-Shirt', 'No notes', '2', '300.00', '1,800.00'),
            _buildOrderDetailRow(
                'Freebies', 'Banner', 'With logo', '1', '400.00', '400.00'),
          ],
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'TOTAL: Php 10,000.00',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              Text(
                'MOP: GCash',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                'Downpayment: Php 5,000.00',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              Text(
                'Balance: Php 5,000.00',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: () {
            Printing.layoutPdf(
              onLayout: (format) => _generatePdf(),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding:
                const EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'PRINT',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 255, 17, 0),
            padding:
                const EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'CONFIRM ORDER',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Future<Uint8List> _generatePdf() async {
    final pdf = pw.Document();

    final image = pw.MemoryImage(
      (await rootBundle.load('assets/images/logo_1.png')).buffer.asUint8List(),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(image, height: 108, width: 108),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'CUSTOMER RECEIPT',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'CBD II Triangulo, Naga City, Camarines Sur\nzuscustoms2021@gmail.com\n0998 226 1132 | 0945 533 1129',
                        textAlign: pw.TextAlign.right,
                        style: const pw.TextStyle(
                            fontSize: 10, color: PdfColors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  _buildPdfCheckboxWithLabel('Regular Order', true),
                  _buildPdfCheckboxWithLabel('Rush Order', false),
                  _buildPdfCheckboxWithLabel('Big Order', false),
                  _buildPdfCheckboxWithLabel('Philgeps Order', false),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Text('CUSTOMERS INFORMATION',
                  style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red)),
              pw.SizedBox(height: 8),
              pw.Text('Customer Name: Alice Guo',
                  style:
                      const pw.TextStyle(fontSize: 12, color: PdfColors.black)),
              pw.Text('Contact: +63927 865 5333',
                  style:
                      const pw.TextStyle(fontSize: 12, color: PdfColors.black)),
              pw.Text('Address: Naga City',
                  style:
                      const pw.TextStyle(fontSize: 12, color: PdfColors.black)),
              pw.Text('Email Address: AliceGuo@gmail.com',
                  style:
                      const pw.TextStyle(fontSize: 12, color: PdfColors.black)),
              pw.Text('Order ID: 0001',
                  style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red)),
              pw.SizedBox(height: 16),
              pw.Text('CLASSIFICATION',
                  style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red)),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  _buildPdfCheckboxWithLabel('New Order', false),
                  _buildPdfCheckboxWithLabel('Additional', true),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Text('ORDER DETAILS',
                  style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red)),
              pw.SizedBox(height: 8),
              // ignore: deprecated_member_use
              pw.Table.fromTextArray(
                headers: [
                  'ITEM',
                  'DESCRIPTION',
                  'NOTES',
                  'QTY',
                  'ORIG PRICE',
                  'TOTAL'
                ],
                data: [
                  [
                    'Uniform',
                    'Jersey Set',
                    'No notes',
                    '12',
                    '500.00',
                    '7,800.00'
                  ],
                  ['Uniform', 'T-Shirt', 'No notes', '2', '300.00', '1,800.00'],
                  ['Freebies', 'Banner', 'With logo', '1', '400.00', '400.00'],
                ],
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  fontSize: 12,
                ),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey600),
                cellStyle: const pw.TextStyle(fontSize: 10),
                cellAlignment: pw.Alignment.centerLeft,
                border: pw.TableBorder.all(color: PdfColors.grey),
              ),
              pw.SizedBox(height: 20),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('TOTAL: Php 10,000.00',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.red)),
                    pw.Text('MOP: GCash',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black)),
                    pw.Text('Downpayment: Php 5,000.00',
                        style: const pw.TextStyle(color: PdfColors.black)),
                    pw.Text('Balance: Php 5,000.00',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.red)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildPdfCheckboxWithLabel(String label, bool isChecked) {
    return pw.Row(
      children: [
        pw.Container(
          width: 12,
          height: 12,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: 1),
          ),
          child: isChecked
              ? pw.Center(
                  child: pw.Container(
                    width: 8,
                    height: 8,
                    color: PdfColors.black,
                  ),
                )
              : null,
        ),
        pw.SizedBox(width: 4),
        pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
        pw.SizedBox(width: 10),
      ],
    );
  }

  Widget _buildInlineTextDisplay(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassificationOption(String label, bool value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: value,
          onChanged: null,
          activeColor: Colors.black,
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildCheckboxWithLabel(String label, bool isChecked) {
    return Row(
      children: [
        Checkbox(
          value: isChecked,
          onChanged: null,
          activeColor: Colors.black,
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _buildTableHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  TableRow _buildOrderDetailRow(String item, String description, String notes,
      String qty, String origPrice, String total) {
    return TableRow(
      children: [
        _buildCenteredTableCell(item),
        _buildCenteredTableCell(description),
        _buildCenteredTableCell(notes),
        _buildCenteredTableCell(qty),
        _buildCenteredTableCell(origPrice),
        _buildCenteredTableCell(total),
      ],
    );
  }

  Widget _buildCenteredTableCell(String value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.black,
          ),
        ),
      ),
    );
  }


  Widget _buildMaterialAvailabilityCheck() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Material Availability Check',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            Table(
              border: TableBorder.all(color: Colors.grey[300]!),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2),
                4: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                  ),
                  children: [
                    _buildTableHeader('Material Name'),
                    _buildTableHeader('Required Quantity'),
                    _buildTableHeader('Available Stock'),
                    _buildTableHeader('Status'),
                    _buildTableHeader('Last Updated'),
                  ],
                ),
                _buildMaterialDetailRow('Fabric', '15 meters', '20 meters',
                    'Available', '10/01/2024'),
                _buildMaterialDetailRow('Buttons', '100 pieces', '80 pieces',
                    'Low Stock', '09/30/2024'),
                _buildMaterialDetailRow(
                    'Ink', '2 liters', '0 liter', 'Out of Stock', '10/01/2024'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildMaterialDetailRow(String material, String requiredQty,
      String availableStock, String status, String lastUpdated) {
    return TableRow(
      children: [
        _buildCenteredTableCell(material),
        _buildCenteredTableCell(requiredQty),
        _buildCenteredTableCell(availableStock),
        _buildCenteredTableCell(status),
        _buildCenteredTableCell(lastUpdated),
      ],
    );
  }

  Widget _buildAttachments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attachments:',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Sketch.png\nLogo.png\nOrder List (Excel File)',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
