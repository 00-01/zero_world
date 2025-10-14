import 'package:flutter/material.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double balance = 1250.50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _showQRCode(),
            icon: const Icon(Icons.qr_code),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Balance Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade400, Colors.teal.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Available Balance',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${balance.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBalanceAction(
                        'Add Money',
                        Icons.add,
                        () => _addMoney(),
                      ),
                      _buildBalanceAction(
                        'Send',
                        Icons.send,
                        () => _sendMoney(),
                      ),
                      _buildBalanceAction(
                        'Request',
                        Icons.call_received,
                        () => _requestMoney(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildQuickAction('Pay Bills', Icons.receipt, Colors.blue),
                  _buildQuickAction(
                    'Mobile Recharge',
                    Icons.phone_android,
                    Colors.green,
                  ),
                  _buildQuickAction('Split Bill', Icons.group, Colors.orange),
                  _buildQuickAction(
                    'Scan & Pay',
                    Icons.qr_code_scanner,
                    Colors.purple,
                  ),
                  _buildQuickAction(
                    'Bank Transfer',
                    Icons.account_balance,
                    Colors.red,
                  ),
                  _buildQuickAction(
                    'Investments',
                    Icons.trending_up,
                    Colors.indigo,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Recent Transactions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => _viewAllTransactions(),
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(5, (index) => _buildTransactionItem(index)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceAction(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(String title, IconData icon, Color color) {
    return Card(
      child: InkWell(
        onTap: () => _performQuickAction(title),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(int index) {
    final transactions = [
      {
        'type': 'Food Delivery',
        'amount': -25.99,
        'icon': Icons.restaurant,
        'time': '2 hours ago',
      },
      {
        'type': 'Money Received',
        'amount': 100.00,
        'icon': Icons.call_received,
        'time': '1 day ago',
      },
      {
        'type': 'Mobile Recharge',
        'amount': -20.00,
        'icon': Icons.phone_android,
        'time': '2 days ago',
      },
      {
        'type': 'Bill Payment',
        'amount': -85.50,
        'icon': Icons.receipt,
        'time': '3 days ago',
      },
      {
        'type': 'Cashback',
        'amount': 5.00,
        'icon': Icons.card_giftcard,
        'time': '5 days ago',
      },
    ];

    final transaction = transactions[index];
    final isIncome = (transaction['amount'] as double) > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isIncome
              ? Colors.green.shade100
              : Colors.red.shade100,
          child: Icon(
            transaction['icon'] as IconData,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
        title: Text(transaction['type'] as String),
        subtitle: Text(transaction['time'] as String),
        trailing: Text(
          '${isIncome ? '+' : ''}\$${(transaction['amount'] as double).abs().toStringAsFixed(2)}',
          style: TextStyle(
            color: isIncome ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _addMoney() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add Money to Wallet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Money added successfully!'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Add Money'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _sendMoney() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Send money feature coming soon!')),
    );
  }

  void _requestMoney() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request money feature coming soon!')),
    );
  }

  void _showQRCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('My QR Code'),
        content: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(Icons.qr_code, size: 150, color: Colors.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _performQuickAction(String action) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$action feature coming soon!')));
  }

  void _viewAllTransactions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('View all transactions coming soon!')),
    );
  }
}
