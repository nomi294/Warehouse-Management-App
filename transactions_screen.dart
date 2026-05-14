import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../providers/transaction_provider.dart';
import '../models/transaction.dart'; // Assuming 'Transaction' here is the model class
import 'stock_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // 1. Get the provider data. The type is implicitly inferred but explicitly defined here for clarity.
    final transactionProvider = Provider.of<TransactionProvider>(context);

    // 2. Filter transactions based on the local search query (though the search button uses a delegate).
    final displayedTransactions = _searchQuery.isEmpty
        ? transactionProvider.transactions
        : transactionProvider.transactions.where((tx) =>
    tx.itemName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        tx.type.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // 3. Show the custom search delegate
              showSearch(
                context: context,
                delegate: _TransactionSearchDelegate(transactionProvider.transactions),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: displayedTransactions.isEmpty
            ? Center(
          child: Text('No transactions found.', style: GoogleFonts.poppins(fontSize: 16)),
        )
            : ListView.builder(
          itemCount: displayedTransactions.length,
          itemBuilder: (context, index) {
            final tx = displayedTransactions[index];
            final isIn = tx.type.toLowerCase() == 'in';

            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              // Visual distinction based on transaction type
              color: isIn ? Colors.green[50] : Colors.red[50],
              child: ListTile(
                title: Text(
                  tx.itemName,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: isIn ? Colors.green[800] : Colors.red[800],
                  ),
                ),
                subtitle: Text(
                  'Quantity: ${tx.quantity}\nDate: ${DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.tryParse(tx.date) ?? DateTime.now())}',
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.grey),
                  onPressed: () async {
                    // Handle deletion
                    try {
                      await transactionProvider.deleteTransaction(tx.id!);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Transaction deleted successfully.')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to delete transaction: $e')),
                        );
                      }
                    }
                  },
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the transaction creation screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StockTransactionScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// Custom Search Delegate for Transactions
// ----------------------------------------------------------------------

class _TransactionSearchDelegate extends SearchDelegate<WarehouseTransaction?> {
  final List<WarehouseTransaction> transactions; // Uses 'WarehouseTransaction'

  _TransactionSearchDelegate(this.transactions);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    // Filter results based on search query
    final results = transactions.where((tx) =>
    tx.itemName.toLowerCase().contains(query.toLowerCase()) ||
        tx.type.toLowerCase().contains(query.toLowerCase())
    ).toList();
    return _buildResultsList(context, results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context); // Show results as suggestions type
  }

  Widget _buildResultsList(BuildContext context, List<WarehouseTransaction> results) {
    if (results.isEmpty) {
      return Center(child: Text('No transactions found.', style: GoogleFonts.poppins(fontSize: 16)));
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final tx = results[index];
        final isIn = tx.type.toLowerCase() == 'in';

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: isIn ? Colors.green[50] : Colors.red[50],
          child: ListTile(
            title: Text(tx.itemName,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: isIn ? Colors.green[800] : Colors.red[800],
                )),
            subtitle: Text(
              'Quantity: ${tx.quantity}\nDate: ${DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.tryParse(tx.date) ?? DateTime.now())}',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
            isThreeLine: true,
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.grey),
              onPressed: () async {
                // Get provider without listening for deletion
                final provider = Provider.of<TransactionProvider>(context, listen: false);
                try {
                  await provider.deleteTransaction(tx.id!);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Transaction deleted successfully.')),
                    );
                    // Close the search screen after successful deletion
                    close(context, null);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete transaction: $e')),
                    );
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }
}