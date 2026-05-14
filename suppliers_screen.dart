// lib/screens/supplier_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

import '../models/supplier.dart';
import '../providers/supplier_provider.dart';
import 'add_edit_supplier_screen.dart';

class SupplierScreen extends StatefulWidget {
  const SupplierScreen({Key? key}) : super(key: key);

  @override
  State<SupplierScreen> createState() => _SupplierScreenState();
}

class _SupplierScreenState extends State<SupplierScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final supplierProvider = Provider.of<SupplierProvider>(context);
    final theme = Theme.of(context);
    final displayedSuppliers = _searchQuery.isEmpty
        ? supplierProvider.suppliers
        : supplierProvider.searchSuppliers(_searchQuery);

    return Scaffold(
      appBar: AppBar(
        title: Text('Suppliers',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 2,
        backgroundColor: theme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _SupplierSearchDelegate(supplierProvider),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: displayedSuppliers.isEmpty
            ? Center(
          child: Text(
            'No suppliers found.',
            style: GoogleFonts.poppins(
                fontSize: 16, color: theme.hintColor),
          ),
        )
            : ListView.builder(
          itemCount: displayedSuppliers.length,
          itemBuilder: (context, index) {
            final sup = displayedSuppliers[index];
            return FadeInUp(
              duration: Duration(milliseconds: 300 + index * 100),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 3,
                margin: const EdgeInsets.symmetric(
                    vertical: 6, horizontal: 4),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    // Optional: view supplier details
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                      theme.primaryColor.withOpacity(0.2),
                      child: Text(
                        sup.name.isNotEmpty
                            ? sup.name[0].toUpperCase()
                            : '?',
                        style: GoogleFonts.poppins(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(sup.name,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      'Company: ${sup.company}\nContact: ${sup.contact}\nEmail: ${sup.email}\nAddress: ${sup.address}',
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit,
                              color: theme.colorScheme.secondary),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      AddEditSupplierScreen(
                                          supplier: sup)),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete,
                              color:
                              Theme.of(context).colorScheme.error),
                          onPressed: () {
                            if (sup.id != null) {
                              _showDeleteDialog(
                                  context, sup, supplierProvider);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.primaryColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditSupplierScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, Supplier sup, SupplierProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Supplier', style: GoogleFonts.poppins()),
        content: Text('Are you sure you want to delete ${sup.name}?',
            style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            child: Text('Cancel', style: GoogleFonts.poppins()),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: GoogleFonts.poppins()),
            onPressed: () async {
              if (sup.id != null) {
                await provider.deleteSupplier(sup.id!);
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

/// Custom SearchDelegate for supplier search
class _SupplierSearchDelegate extends SearchDelegate<Supplier?> {
  final SupplierProvider provider;

  _SupplierSearchDelegate(this.provider);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = provider.searchSuppliers(query);
    return _buildList(results, context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = provider.searchSuppliers(query);
    return _buildList(suggestions, context);
  }

  Widget _buildList(List<Supplier> list, BuildContext context) {
    final theme = Theme.of(context);
    if (list.isEmpty) {
      return Center(
        child: Text(
          'No suppliers found.',
          style: GoogleFonts.poppins(fontSize: 16, color: theme.hintColor),
        ),
      );
    }

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final sup = list[index];
        return FadeInUp(
          duration: Duration(milliseconds: 200 + index * 100),
          child: Card(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.primaryColor.withOpacity(0.2),
                child: Text(
                  sup.name.isNotEmpty ? sup.name[0].toUpperCase() : '?',
                  style: GoogleFonts.poppins(
                      color: theme.primaryColor, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(sup.name,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              subtitle: Text(
                'Company: ${sup.company}\nContact: ${sup.contact}\nEmail: ${sup.email}\nAddress: ${sup.address}',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: theme.colorScheme.secondary),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                AddEditSupplierScreen(supplier: sup)),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete,
                        color: Theme.of(context).colorScheme.error),
                    onPressed: () async {
                      if (sup.id != null) {
                        await provider.deleteSupplier(sup.id!);
                      } else {
                        print("Error: Supplier ID is null!");
                      }
                        close(context, null); // close search after deletion
                      }

                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
