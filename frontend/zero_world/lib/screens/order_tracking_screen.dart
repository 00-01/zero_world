import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/conversation_provider.dart';
import '../services/concierge_service.dart';

/// Order Tracking Screen
/// Real-time order status and delivery tracking
class OrderTrackingScreen extends StatelessWidget {
  final String orderId;
  final String provider;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        elevation: 0,
        title: const Text(
          'Track Order',
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFFFFF)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<ConversationProvider>(
        builder: (context, conversationProvider, _) {
          final order = conversationProvider.currentOrder;
          final updates = conversationProvider.orderUpdates;

          if (order == null) {
            return const Center(
              child: Text(
                'No active order',
                style: TextStyle(color: Color(0xFF666666)),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order ID
                _buildOrderHeader(order),
                
                const SizedBox(height: 24),

                // Current Status
                _buildCurrentStatus(order.status, updates.isNotEmpty ? updates.last : null),

                const SizedBox(height: 32),

                // Status Timeline
                _buildStatusTimeline(updates),

                const SizedBox(height: 32),

                // Order Details
                _buildOrderDetails(order),

                const SizedBox(height: 24),

                // Action Buttons
                _buildActionButtons(context, conversationProvider, order),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderHeader(Order order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1A1A1A),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order ID',
            style: TextStyle(
              color: Color(0xFF999999),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            order.orderId,
            style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 14,
                color: Color(0xFF666666),
              ),
              const SizedBox(width: 4),
              Text(
                _formatDateTime(order.createdAt),
                style: const TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStatus(String status, OrderStatusUpdate? latestUpdate) {
    final statusInfo = _getStatusInfo(status);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusInfo.color.withOpacity(0.2),
            statusInfo.color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusInfo.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            statusInfo.icon,
            size: 64,
            color: statusInfo.color,
          ),
          const SizedBox(height: 16),
          Text(
            statusInfo.title,
            style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (latestUpdate != null)
            Text(
              latestUpdate.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF999999),
                fontSize: 15,
              ),
            ),
          if (latestUpdate?.eta != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.schedule,
                    size: 16,
                    color: Color(0xFFFFFFFF),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ETA: ${latestUpdate!.eta} min',
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(List<OrderStatusUpdate> updates) {
    if (updates.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Timeline',
          style: TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...updates.asMap().entries.map((entry) {
          final index = entry.key;
          final update = entry.value;
          final isLast = index == updates.length - 1;
          
          return _buildTimelineItem(update, isLast);
        }).toList(),
      ],
    );
  }

  Widget _buildTimelineItem(OrderStatusUpdate update, bool isLast) {
    final statusInfo = _getStatusInfo(update.status);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: statusInfo.color.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: statusInfo.color,
                  width: 2,
                ),
              ),
              child: Icon(
                statusInfo.icon,
                size: 20,
                color: statusInfo.color,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: const Color(0xFF1A1A1A),
              ),
          ],
        ),
        const SizedBox(width: 16),
        
        // Status info
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  update.message,
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(update.timestamp),
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderDetails(Order order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1A1A1A),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Details',
            style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // Order details from orderDetails map
          ...order.orderDetails.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatKey(entry.key),
                    style: const TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 14,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      '${entry.value}',
                      style: const TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          
          const Divider(color: Color(0xFF1A1A1A), height: 32),
          
          // Total cost
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '\$${order.totalCost.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ConversationProvider provider, Order order) {
    return Column(
      children: [
        if (order.trackingUrl != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Open tracking URL
                // In web: js.context.callMethod('open', [order.trackingUrl]);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tracking URL: ${order.trackingUrl}')),
                );
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('View in Provider App'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFFFFF),
                foregroundColor: const Color(0xFF000000),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              provider.refreshOrderStatus(order.orderId, this.provider);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh Status'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFFFFFF),
              side: const BorderSide(color: Color(0xFF333333)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showCancelDialog(context, provider, order),
            icon: const Icon(Icons.cancel),
            label: const Text('Cancel Order'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFF6666),
              side: const BorderSide(color: Color(0xFF550000)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showCancelDialog(BuildContext context, ConversationProvider provider, Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Cancel Order?',
          style: TextStyle(color: Color(0xFFFFFFFF)),
        ),
        content: const Text(
          'Are you sure you want to cancel this order?',
          style: TextStyle(color: Color(0xFF999999)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Keep Order',
              style: TextStyle(color: Color(0xFF999999)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              provider.cancelOrder(order.orderId, this.provider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6666),
              foregroundColor: const Color(0xFFFFFFFF),
            ),
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );
  }

  StatusInfo _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'placed':
      case 'confirmed':
        return StatusInfo(
          icon: Icons.check_circle,
          title: 'Order Confirmed',
          color: const Color(0xFF00AA00),
        );
      case 'preparing':
        return StatusInfo(
          icon: Icons.restaurant,
          title: 'Preparing',
          color: const Color(0xFFFFAA00),
        );
      case 'ready':
        return StatusInfo(
          icon: Icons.done_all,
          title: 'Ready',
          color: const Color(0xFF00AAFF),
        );
      case 'picked_up':
      case 'in_transit':
        return StatusInfo(
          icon: Icons.local_shipping,
          title: 'On the Way',
          color: const Color(0xFF8800FF),
        );
      case 'nearby':
        return StatusInfo(
          icon: Icons.near_me,
          title: 'Nearby',
          color: const Color(0xFFFF00AA),
        );
      case 'arrived':
      case 'delivered':
        return StatusInfo(
          icon: Icons.celebration,
          title: 'Delivered!',
          color: const Color(0xFF00FF00),
        );
      case 'cancelled':
        return StatusInfo(
          icon: Icons.cancel,
          title: 'Cancelled',
          color: const Color(0xFFFF0000),
        );
      default:
        return StatusInfo(
          icon: Icons.info,
          title: status,
          color: const Color(0xFF666666),
        );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${_formatTime(dateTime)}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}

class StatusInfo {
  final IconData icon;
  final String title;
  final Color color;

  StatusInfo({
    required this.icon,
    required this.title,
    required this.color,
  });
}
