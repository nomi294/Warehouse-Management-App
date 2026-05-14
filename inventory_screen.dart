// lib/screens/inventory_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/item.dart';
import '../providers/item_provider.dart';
import 'add_edit_item_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    // Load Firestore Items
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final itemProvider = Provider.of<ItemProvider>(context, listen: false);

      // if (itemProvider.items.isEmpty) {
      //   await itemProvider.loadItems(); // 🔥 Firestore load
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);

    // Search filter logic stays same
    final displayedItems = _searchQuery.isEmpty
        ? itemProvider.items
        : itemProvider.searchItems(_searchQuery);

    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _ItemSearchDelegate(itemProvider.items),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: itemProvider.items.isEmpty
            ? Center(
          child: Text(
            'No items found.',
            style: GoogleFonts.poppins(fontSize: 16),
          ),
        )
            : ListView.builder(
          itemCount: displayedItems.length,
          itemBuilder: (context, index) {
            final item = displayedItems[index];
            final isLowStock = item.quantity < 10;

            return Card(
              color: isLowStock ? Colors.red[50] : Colors.white,
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isLowStock
                    ? const BorderSide(color: Colors.red, width: 1)
                    : BorderSide.none,
              ),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    item.getImage(),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  item.name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: isLowStock ? Colors.red[800] : Colors.black,
                  ),
                ),
                subtitle: Text(
                  'SKU: ${item.sku}\nCategory: ${item.category}\nQuantity: ${item.quantity} ${item.unit}\nLocation: ${item.location}\nSupplier: ${item.supplier}',
                  style: GoogleFonts.poppins(fontSize: 13),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => AddEditItemScreen(item: item)),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.grey),
                      onPressed: () {
                        Provider.of<ItemProvider>(context, listen: false)
                            .deleteItem(item.id!); // 🔥 Firestore delete
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<Item?>(
            context,
            MaterialPageRoute(builder: (_) => const AddEditItemScreen()),
          );

          if (result != null) {
            await Provider.of<ItemProvider>(context, listen: false);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ---------------------- SEARCH DELEGATE -------------------------

class _ItemSearchDelegate extends SearchDelegate {
  final List<Item> items;

  _ItemSearchDelegate(this.items);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = items
        .where((item) =>
    item.name.toLowerCase().contains(query.toLowerCase()) ||
        item.category.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return _buildResultsList(context, results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = items
        .where((item) =>
    item.name.toLowerCase().contains(query.toLowerCase()) ||
        item.category.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return _buildResultsList(context, suggestions);
  }

  Widget _buildResultsList(BuildContext context, List<Item> items) {
    if (items.isEmpty) {
      return Center(
        child: Text('No items found.', style: GoogleFonts.poppins(fontSize: 16)),
      );
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isLowStock = item.quantity < 10;

        return Card(
          color: isLowStock ? Colors.red[50] : Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isLowStock
                ? const BorderSide(color: Colors.red, width: 1)
                : BorderSide.none,
          ),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                item.getImage(),
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              item.name,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: isLowStock ? Colors.red[800] : Colors.black,
              ),
            ),
            subtitle: Text(
              'SKU: ${item.sku}\nCategory: ${item.category}\nQuantity: ${item.quantity} ${item.unit}\nLocation: ${item.location}\nSupplier: ${item.supplier}',
              style: GoogleFonts.poppins(fontSize: 13),
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => AddEditItemScreen(item: item)),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.grey),
                  onPressed: () {
                    Provider.of<ItemProvider>(context, listen: false)
                        .deleteItem(item.id!);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
