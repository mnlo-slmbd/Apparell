import 'package:flutter/material.dart';

// Admin Imports
import 'package:logistic_management_system/Admin/add_new_customer.dart';
import 'package:logistic_management_system/Admin/admin_dashboard.dart';
import 'package:logistic_management_system/Admin/admin_expenses.dart';
import 'package:logistic_management_system/Admin/admin_finished_products.dart';
import 'package:logistic_management_system/Admin/admin_reports.dart';
import 'package:logistic_management_system/Admin/customer_history.dart';
import 'package:logistic_management_system/Admin/job_order_request.dart';
import 'package:logistic_management_system/Admin/product_list.dart';
import 'package:logistic_management_system/Admin/task_assign.dart';
import 'package:logistic_management_system/Admin/user_management.dart';
import 'package:logistic_management_system/Admin/user_registration.dart';
import 'package:logistic_management_system/Admin/monthly_sales_report.dart';

// Graphic Artist
import 'package:logistic_management_system/GraphicArtist/graphic_artist.dart';

// Partner Store
import 'package:logistic_management_system/PartnerStore/additional_order.dart';
import 'package:logistic_management_system/PartnerStore/customers_copy.dart';
import 'package:logistic_management_system/PartnerStore/login_page.dart';
import 'package:logistic_management_system/PartnerStore/sample_purchase.dart';
import 'package:logistic_management_system/PartnerStore/store_expenses.dart';
import 'package:logistic_management_system/PartnerStore/store_reports.dart';
import 'package:logistic_management_system/PartnerStore/store_sales.dart';

// Warehouse Dashboard
import 'package:logistic_management_system/WarehouseDashboard/delivery.dart';
import 'package:logistic_management_system/WarehouseDashboard/inventory.dart';
import 'package:logistic_management_system/WarehouseDashboard/printing.dart';
import 'package:logistic_management_system/WarehouseDashboard/printing_view.dart';
import 'package:logistic_management_system/WarehouseDashboard/production_monitoring.dart';
import 'package:logistic_management_system/WarehouseDashboard/quality_check.dart';
import 'package:logistic_management_system/WarehouseDashboard/tailoring_view.dart';
import 'package:logistic_management_system/WarehouseDashboard/test_print.dart';
import 'package:logistic_management_system/WarehouseDashboard/tailoring.dart';
import 'package:logistic_management_system/WarehouseDashboard/test_print_view.dart';
import 'package:logistic_management_system/WarehouseDashboard/warehouse_dashboard.dart';
import 'package:logistic_management_system/WarehouseDashboard/rename.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Logistics Management System',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      initialRoute: '/login_page',
      routes: {
        // Admin Routes
        '/add-new-customer': (context) => const AddNewCustomer(),
        '/admin-dashboard': (context) => const AdminDashboard(),
        '/admin_reports': (context) => const AdminReports(),
        '/customer-history': (context) => const CustomerHistory(),
        '/job-order-request': (context) => const JobOrderRequest(),
        '/monthly_sales_report': (context) => const MonthlySalesReport(),
        '/product-list': (context) => const ProductList(),
        '/user-management': (context) => const UserManagement(),
        '/user-registration': (context) => const UserRegistration(),
        '/task_assign': (context) => const TaskAssignPage(),
        '/admin_finished_products': (context) => const FinishedProduct(),
        '/admin_expenses': (context) => const AdminExpenses(),

        // Graphic Artist
        '/graphic_artist_task': (context) =>
            const GraphicArtistTask(assignee: ''),

        // Partner Store Static Routes
        '/additional-order': (context) => const AdditionalOrder(),
        '/customers-copy': (context) => CustomersCopy(),
        '/login_page': (context) => const LoginPage(),
        '/store_reports': (context) => const StoreReports(
              storeName: '',
            ),
        '/store_expenses': (context) => const StoreExpenses(storeName: '',),

        // Warehouse Dashboard
        '/delivery': (context) => const Delivery(),
        '/inventory': (context) => const Inventory(),
        '/production_monitoring': (context) => const ProductionMonitoring(),
        '/printing': (context) => const Printing(),
        '/quality_check': (context) => const QualityCheck(),
        '/tailoring': (context) => const Tailoring(),
        '/test_print': (context) => const TestPrint(),
        '/test_print_view': (context) => const TestPrintView(),
        '/warehouse_dashboard': (context) => const WarehouseDashboard(),
        '/rename': (context) => const WarehouseRename(),
        '/printing_view': (context) => const PrintingView(),
        '/tailoring_view': (context) => const TailoringView(),
      },

      // 🔥 Handle dynamic routes with arguments (like storeName)
      onGenerateRoute: (settings) {
        if (settings.name == '/sample_purchase') {
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          final storeName = args['storeName'] ?? '';
          return MaterialPageRoute(
            builder: (context) => PurchaseOrderForms(storeName: storeName),
          );
        }

        if (settings.name == '/store_sales') {
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          final storeName = args['storeName'] ?? '';
          return MaterialPageRoute(
            builder: (context) => StoreSales(storeName: storeName),
          );
        }

        if (settings.name == '/store_expenses') {
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          final storeName = args['storeName'] ?? '';
          return MaterialPageRoute(
            builder: (context) => StoreExpenses(storeName: storeName),
          );
        }

        return null;
      },

      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const UndefinedRoutePage(),
        );
      },
    );
  }
}

class UndefinedRoutePage extends StatelessWidget {
  const UndefinedRoutePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: const Center(
        child: Text(
          'The page you are looking for does not exist!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
