/// Invoicing Screen
/// Invoice management and creation interface

import 'package:flutter/material.dart';
import '../models/business.dart';
import '../services/business_service.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> with SingleTickerProviderStateMixin {
  final BusinessService _businessService = BusinessService();
  late TabController _tabController;

  List<Invoice> _invoices = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadInvoices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInvoices() async {
    setState(() => _isLoading = true);
    try {
      // Load mock data for now
      _invoices = _getMockInvoices();
    } catch (e) {
      _showError('Failed to load invoices: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Draft'),
            Tab(text: 'Sent'),
            Tab(text: 'Paid'),
            Tab(text: 'Overdue'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildInvoiceList(_invoices),
                _buildInvoiceList(_invoices.where((i) => i.status == 'draft').toList()),
                _buildInvoiceList(_invoices.where((i) => i.status == 'sent').toList()),
                _buildInvoiceList(_invoices.where((i) => i.status == 'paid').toList()),
                _buildInvoiceList(_invoices.where((i) => i.isOverdue).toList()),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateInvoiceDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Invoice'),
      ),
    );
  }

  Widget _buildInvoiceList(List<Invoice> invoices) {
    if (invoices.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No invoices found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: invoices.length,
      itemBuilder: (context, index) => _buildInvoiceCard(invoices[index]),
    );
  }

  Widget _buildInvoiceCard(Invoice invoice) {
    final statusColor = _getStatusColor(invoice.status);
    final isOverdue = invoice.isOverdue;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showInvoiceDetails(invoice),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invoice #${invoice.invoiceNumber}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          invoice.customerName,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      isOverdue ? 'OVERDUE' : invoice.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Amount and Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amount',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${invoice.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Due Date',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(invoice.dueDate),
                        style: TextStyle(
                          fontSize: 14,
                          color: isOverdue ? Colors.red : Colors.black87,
                          fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Actions
              Row(
                children: [
                  if (invoice.status == 'draft') ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _sendInvoice(invoice),
                        icon: const Icon(Icons.send, size: 18),
                        label: const Text('Send'),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (invoice.status == 'sent') ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _markAsPaid(invoice),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Mark Paid'),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showInvoiceDetails(invoice),
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('View'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showInvoiceOptions(invoice),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'draft':
        return Colors.grey;
      case 'sent':
        return Colors.blue;
      case 'paid':
        return Colors.green;
      case 'overdue':
        return Colors.red;
      case 'cancelled':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showInvoiceDetails(Invoice invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: ListView(
              controller: scrollController,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'INVOICE',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '#${invoice.invoiceNumber}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Customer Info
                Text(
                  'BILL TO',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  invoice.customerName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (invoice.customerEmail != null) Text(invoice.customerEmail!),
                const SizedBox(height: 24),

                // Dates
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Issue Date',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(_formatDate(invoice.issueDate)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Due Date',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(_formatDate(invoice.dueDate)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Items
                const Text(
                  'ITEMS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(3),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1),
                    3: FlexColumnWidth(1),
                  },
                  border: TableBorder.all(color: Colors.grey[300]!),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey[100]),
                      children: [
                        _tableCell('Description', isHeader: true),
                        _tableCell('Qty', isHeader: true),
                        _tableCell('Price', isHeader: true),
                        _tableCell('Total', isHeader: true),
                      ],
                    ),
                    ...invoice.items.map((item) {
                      return TableRow(
                        children: [
                          _tableCell(item.description),
                          _tableCell(item.quantity.toString()),
                          _tableCell('\$${item.unitPrice.toStringAsFixed(2)}'),
                          _tableCell('\$${item.total.toStringAsFixed(2)}'),
                        ],
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 16),

                // Totals
                Column(
                  children: [
                    _buildTotalRow('Subtotal', invoice.subtotal),
                    if (invoice.discount > 0) _buildTotalRow('Discount', -invoice.discount, isNegative: true),
                    _buildTotalRow('Tax', invoice.tax),
                    const Divider(thickness: 2),
                    _buildTotalRow(
                      'TOTAL',
                      invoice.total,
                      isBold: true,
                      isLarge: true,
                    ),
                  ],
                ),

                // Notes
                if (invoice.notes != null) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'NOTES',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(invoice.notes!),
                ],

                // Payment Info
                if (invoice.isPaid) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 8),
                            const Text(
                              'PAID',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Paid on: ${_formatDate(invoice.paidAt!)}'),
                        if (invoice.paymentMethod != null) Text('Method: ${invoice.paymentMethod}'),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _tableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildTotalRow(
    String label,
    double amount, {
    bool isBold = false,
    bool isLarge = false,
    bool isNegative = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isLarge ? 18 : 14,
            ),
          ),
          Text(
            '${isNegative ? '-' : ''}\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isLarge ? 18 : 14,
              color: isNegative ? Colors.red : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateInvoiceDialog() {
    // TODO: Implement full invoice creation form
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invoice creation not implemented yet')),
    );
  }

  void _sendInvoice(Invoice invoice) {
    // TODO: Send invoice via email
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Invoice #${invoice.invoiceNumber} sent')),
    );
  }

  void _markAsPaid(Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Paid'),
        content: const Text('Confirm that this invoice has been paid?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Mark invoice as paid
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invoice marked as paid')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showInvoiceOptions(Invoice invoice) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Edit invoice
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('Download PDF'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Download PDF
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Share invoice
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _confirmDeleteInvoice(invoice);
            },
          ),
        ],
      ),
    );
  }

  void _confirmDeleteInvoice(Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: Text('Are you sure you want to delete invoice #${invoice.invoiceNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Delete invoice
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invoice deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Mock data
  List<Invoice> _getMockInvoices() {
    return List.generate(15, (index) {
      final statuses = ['draft', 'sent', 'paid', 'sent'];
      final status = statuses[index % statuses.length];
      final issueDate = DateTime.now().subtract(Duration(days: index * 5));
      final dueDate = issueDate.add(const Duration(days: 30));

      return Invoice(
        id: 'invoice_$index',
        businessId: 'business_1',
        customerId: 'customer_${index % 10}',
        customerName: 'Customer ${index + 1}',
        customerEmail: 'customer${index + 1}@example.com',
        invoiceNumber: (1000 + index).toString(),
        issueDate: issueDate,
        dueDate: dueDate,
        items: [
          InvoiceItem(
            description: 'Product/Service ${index + 1}',
            quantity: (index % 5) + 1,
            unitPrice: 100.0 + (index * 10),
            total: ((index % 5) + 1) * (100.0 + (index * 10)),
          ),
          InvoiceItem(
            description: 'Consulting Services',
            quantity: (index % 3) + 1,
            unitPrice: 150.0,
            total: ((index % 3) + 1) * 150.0,
          ),
        ],
        subtotal: ((index % 5) + 1) * (100.0 + (index * 10)) + ((index % 3) + 1) * 150.0,
        tax: (((index % 5) + 1) * (100.0 + (index * 10)) + ((index % 3) + 1) * 150.0) * 0.1,
        discount: index % 4 == 0 ? 50.0 : 0,
        total: ((index % 5) + 1) * (100.0 + (index * 10)) + ((index % 3) + 1) * 150.0 + (((index % 5) + 1) * (100.0 + (index * 10)) + ((index % 3) + 1) * 150.0) * 0.1 - (index % 4 == 0 ? 50.0 : 0),
        status: status,
        notes: 'Thank you for your business!',
        paymentMethod: status == 'paid' ? 'Credit Card' : null,
        paidAt: status == 'paid' ? DateTime.now().subtract(Duration(days: index * 2)) : null,
        createdAt: issueDate,
      );
    });
  }
}
