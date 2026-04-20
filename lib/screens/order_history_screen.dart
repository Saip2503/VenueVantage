import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import '../providers/auth_state.dart';
import '../providers/app_state.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../utils/error_utils.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStateProvider>();
    final appState = context.watch<AppState>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Order History',
          style: GoogleFonts.inter(
            color: AppTheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      body: Column(
        children: [
          if (appState.activeOrderId != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: _ActiveOrderCard(
                orderId: appState.activeOrderId!,
                step: appState.orderStep,
              ),
            ),
          Expanded(
            child: user == null
                ? const _UnauthedView()
                : StreamBuilder<List<OrderModel>>(
                    stream: FirestoreService().ordersStream(user.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: AppTheme.primary),
                        );
                      }
                      if (snapshot.hasError) {
                        return _ErrorView(error: ErrorUtils.getFriendlyMessage(snapshot.error));
                      }
                      final orders = snapshot.data ?? [];
                      if (orders.isEmpty && appState.activeOrderId == null) {
                        return const _NoOrdersView();
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          // Skip active order if it's already shown at the top
                          if (order.id == appState.activeOrderId) return const SizedBox.shrink();
                          return _OrderCard(order: order);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ActiveOrderCard extends StatelessWidget {
  final String orderId;
  final OrderTrackingStep step;

  const _ActiveOrderCard({required this.orderId, required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timer_rounded, color: AppTheme.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                'LIVE ORDER',
                style: GoogleFonts.inter(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Text(
                '#${orderId.substring(0, min(orderId.length, 6)).toUpperCase()}',
                style: GoogleFonts.inter(
                  color: AppTheme.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            _getStepName(),
            style: GoogleFonts.inter(
              color: AppTheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Estimated delivery: 12 min',
            style: GoogleFonts.inter(
              color: AppTheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _getStepName() {
    switch (step) {
      case OrderTrackingStep.placed: return 'Order Placed';
      case OrderTrackingStep.preparing: return 'Kitchen Preparing';
      case OrderTrackingStep.onTheWay: return 'Runner is coming!';
      case OrderTrackingStep.delivered: return 'Delivered to Seat';
    }
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(4, (i) {
        final isActive = i <= step.index;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primary : AppTheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM dd, hh:mm a').format(order.time);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ID: #${order.id.substring(0, 6).toUpperCase()}',
                style: GoogleFonts.inter(
                  color: AppTheme.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              _StatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            dateStr,
            style: GoogleFonts.inter(color: AppTheme.outline, fontSize: 12),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppTheme.outlineVariant, thickness: 0.5),
          const SizedBox(height: 12),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(item.emoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${item.quantity}x ${item.name}',
                      style: GoogleFonts.inter(
                        color: AppTheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Total: ',
                style: GoogleFonts.inter(color: AppTheme.outline, fontSize: 13),
              ),
              Text(
                '\$${order.total.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  color: AppTheme.tertiary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'delivered':
        color = AppTheme.accentGreen;
        break;
      case 'placed':
        color = AppTheme.primary;
        break;
      case 'preparing':
        color = AppTheme.tertiary;
        break;
      default:
        color = AppTheme.outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.inter(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _UnauthedView extends StatelessWidget {
  const _UnauthedView();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.history_rounded,
              size: 64,
              color: AppTheme.outlineVariant,
            ),
            const SizedBox(height: 24),
            Text(
              'Sign in to see your orders',
              style: GoogleFonts.inter(
                color: AppTheme.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoOrdersView extends StatelessWidget {
  const _NoOrdersView();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.receipt_long_rounded,
            size: 64,
            color: AppTheme.outlineVariant,
          ),
          const SizedBox(height: 20),
          Text(
            'No orders yet',
            style: GoogleFonts.inter(
              color: AppTheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your stadium snacking journey starts here.',
            style: GoogleFonts.inter(
              color: AppTheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  const _ErrorView({required this.error});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          error,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: AppTheme.error, fontSize: 14),
        ),
      ),
    );
  }
}
