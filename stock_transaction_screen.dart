// lib/screens/stock_transaction_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import '../models/item.dart';
import '../models/transaction.dart';
import '../providers/item_provider.dart';
import '../providers/transaction_provider.dart';
import 'package:intl/intl.dart';

class StockTransactionScreen extends StatefulWidget {
  const StockTransactionScreen({Key? key}) : super(key: key);

  @override
  State<StockTransactionScreen> createState() => _StockTransactionScreenState();
}

class _StockTransactionScreenState extends State<StockTransactionScreen> {
  Item? _selectedItem;
  String _transactionType = 'in';
  final TextEditingController _quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final primaryColor = Colors.indigo.shade600;
    final bgColor = Colors.grey.shade100;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade500, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Stock In / Out',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 6,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: FadeInDown(
          duration: const Duration(milliseconds: 800),
          child: Column(
            children: [
              // Dropdown wrapped in Consumer
              FadeInLeft(
                duration: const Duration(milliseconds: 700),
                child: Consumer<ItemProvider>(
                  builder: (context, itemProvider, _) {
                    if (itemProvider.items.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return _buildDropdown(itemProvider.items);
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Quantity input
              FadeInLeft(
                duration: const Duration(milliseconds: 800),
                child: TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    prefixIcon: const Icon(
                      Icons.confirmation_number_rounded,
                      color: Colors.indigo,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.indigo.shade100, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.indigo, width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Transaction type
              FadeInLeft(
                duration: const Duration(milliseconds: 900),
                child: Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Stock In'),
                        value: 'in',
                        groupValue: _transactionType,
                        onChanged: (val) {
                          setState(() => _transactionType = val!);
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Stock Out'),
                        value: 'out',
                        groupValue: _transactionType,
                        onChanged: (val) {
                          setState(() => _transactionType = val!);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Submit button
              FadeInUp(
                duration: const Duration(milliseconds: 1000),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: Consumer<ItemProvider>(
                    builder: (context, itemProvider, _) => ElevatedButton.icon(
                      icon: const Icon(Icons.save_rounded, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 5,
                      ),
                      label: Text(
                        'Submit Transaction',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      onPressed: () {
                        if (_selectedItem == null || _quantityController.text.isEmpty) {
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.warning,
                            animType: AnimType.scale,
                            title: 'Oops!',
                            desc: 'Please select an item and enter quantity.',
                            btnOkColor: primaryColor,
                            btnOkOnPress: () {},
                          ).show();
                          return;
                        }

                        final qty = int.tryParse(_quantityController.text);
                        if (qty == null || qty <= 0) {
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.warning,
                            animType: AnimType.scale,
                            title: 'Invalid Quantity',
                            desc: 'Please enter a valid quantity.',
                            btnOkColor: primaryColor,
                            btnOkOnPress: () {},
                          ).show();
                          return;
                        }

                        if (_transactionType == 'in') {
                          _selectedItem!.quantity += qty;
                        } else {
                          if (_selectedItem!.quantity < qty) {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.error,
                              animType: AnimType.scale,
                              title: 'Stock Error',
                              desc: 'Insufficient stock.',
                              btnOkColor: primaryColor,
                              btnOkOnPress: () {},
                            ).show();
                            return;
                          }
                          _selectedItem!.quantity -= qty;
                        }

                        itemProvider.updateItem(_selectedItem!);

                        final transaction = WarehouseTransaction(
                          id: DateTime.now().millisecondsSinceEpoch.toString(), // FIXED
                          itemName: _selectedItem!.name,
                          quantity: qty,
                          type: _transactionType,
                          date: DateTime.now().toIso8601String(),
                        );

                        transactionProvider.addTransaction(transaction);

                        setState(() {
                          _selectedItem = null;
                          _quantityController.clear();
                          _transactionType = 'in';
                        });

                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.success,
                          animType: AnimType.scale,
                          title: 'Success',
                          desc: 'Transaction recorded successfully!',
                          btnOkColor: primaryColor,
                          btnOkOnPress: () {},
                        ).show();
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 12),

              // Transaction history
              SizedBox(
                height: 300,
                child: Consumer<ItemProvider>(
                  builder: (context, itemProvider, _) {
                    final transactions = transactionProvider.transactions;
                    return transactions.isEmpty
                        ? Center(
                      child: Text('No transactions yet', style: GoogleFonts.poppins()),
                    )
                        : ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final tx = transactions[index];
                        final item = itemProvider.items.firstWhere(
                              (i) => i.name == tx.itemName,
                          orElse: () => Item(
                            id: 'unknown',
                            name: tx.itemName,
                            category: '',
                            quantity: 0,
                            unit: '',
                            location: '',
                            supplier: '',
                            dateAdded: DateTime.now().toIso8601String(),  // REQUIRED FIELD ADDED
                            sku: 'N/A',
                            imagePath: 'assets/images/default_item.png',
                          ),
                        );

                        return FadeInUp(
                          duration: Duration(milliseconds: 600 + index * 100),
                          child: Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 6),
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
                                '${tx.itemName} (${tx.type.toUpperCase()})',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                'Quantity: ${tx.quantity}\nDate: ${DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.tryParse(tx.date) ?? DateTime.now())}',
                                style: GoogleFonts.poppins(fontSize: 13),
                              ),

                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(List<Item> items) {
    return DropdownButtonFormField<Item>(
      decoration: InputDecoration(
        labelText: 'Select Item',
        prefixIcon: const Icon(Icons.inventory_2_rounded, color: Colors.indigo),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.indigo.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.indigo, width: 2),
        ),
      ),
      value: _selectedItem,
      items: items.map((item) {
        return DropdownMenuItem<Item>(
          value: item,
          child: Text('${item.name} (${item.quantity} ${item.unit})'),
        );
      }).toList(),
      onChanged: (val) => setState(() => _selectedItem = val),
      validator: (val) => val == null ? 'Select an item' : null,
    );
  }
}
