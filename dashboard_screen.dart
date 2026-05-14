import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// Import necessary files (these must exist in your project)
import '../theme/app_theme.dart';
import '../providers/item_provider.dart';
import '../providers/supplier_provider.dart';
import '../providers/employee_provider.dart';

/// A dashboard screen that displays key metrics from the Item, Supplier, and Employee providers
/// in a grid of gradient cards.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  /// Handles navigation to the appropriate screen when a dashboard card is tapped.
  void _navigate(BuildContext context, String title) {
    switch (title) {
      case 'Total Items':
      case 'Low Stock':
      // Navigate to the Inventory management screen
        Navigator.pushNamed(context, '/inventory');
        break;
      case 'Suppliers':
      // Navigate to the Suppliers management screen
        Navigator.pushNamed(context, '/suppliers');
        break;
      case 'Employees':
      // Navigate to the Employees management screen
        Navigator.pushNamed(context, '/employees');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer3 to access data from three different providers simultaneously.
    return Consumer3<ItemProvider, SupplierProvider, EmployeeProvider>(
      builder: (context, itemProvider, supplierProvider, employeeProvider, _) {
        // Fetch the required metrics
        final totalItems = itemProvider.items.length;
        final lowStockCount = itemProvider.lowStockItems.length; // Assumes this property exists
        final totalSuppliers = supplierProvider.suppliers.length;
        final totalEmployees = employeeProvider.employees.length;

        // Configuration data for the dashboard cards
        final dashboardData = [
          {
            'title': 'Total Items',
            'value': totalItems.toString(),
            'icon': Icons.inventory_2,
            'gradient': AppTheme.yellowGradient // Assuming AppTheme is accessible and contains List<Color> gradients
          },
          {
            'title': 'Low Stock',
            'value': lowStockCount.toString(),
            'icon': Icons.warning,
            'gradient': AppTheme.redGradient
          },
          {
            'title': 'Suppliers',
            'value': totalSuppliers.toString(),
            'icon': Icons.local_shipping,
            'gradient': AppTheme.greenGradient
          },
          {
            'title': 'Employees',
            'value': totalEmployees.toString(),
            'icon': Icons.people,
            'gradient': AppTheme.orangeGradient
          },
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          // Use LayoutBuilder for responsive grid sizing
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate item width for a 2-column layout with 12 unit spacing
              final double itemWidth = (constraints.maxWidth - 12) / 2;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dashboardData.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  // Maintain a consistent height-to-width ratio for the cards
                  childAspectRatio: itemWidth / 140,
                ),
                itemBuilder: (context, index) {
                  final data = dashboardData[index];

                  return GestureDetector(
                    onTap: () => _navigate(context, data['title'].toString()),
                    child: Container(
                      decoration: BoxDecoration(
                        // Apply gradient defined in AppTheme
                        gradient: LinearGradient(
                          colors: data['gradient'] as List<Color>,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(2, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(data['icon'] as IconData, size: 36, color: Colors.white),
                          const SizedBox(height: 10),
                          Text(
                            data['title'].toString(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            data['value'].toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}