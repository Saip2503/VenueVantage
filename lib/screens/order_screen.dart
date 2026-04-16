import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../providers/auth_state.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String _selectedCategory = 'All';
  bool _showCart = false;
  bool _orderPlaced = false;

  List<String> get _categories =>
      ['All', 'Snacks', 'Mains', 'Drinks', 'Desserts'];

  List<MenuItem> _getFiltered(List<MenuItem> items) {
    if (_selectedCategory == 'All') return items;
    return items
        .where((m) => m.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final auth = context.watch<AuthStateProvider>();
    final items = _getFiltered(state.menuItems);

    if (_orderPlaced) return _buildSuccessScreen();

    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              _buildHeader(context),
              _buildCategoryFilter(),
              Expanded(child: _buildMenuList(context, items)),
            ],
          ),
          if (_showCart) _buildCartOverlay(context, auth.user?.uid),
          _buildCartFAB(context),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'In-Seat Ordering',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.onSurface,
              letterSpacing: -0.02 * 24,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.chair_rounded,
                  size: 14, color: AppTheme.tertiary),
              const SizedBox(width: 5),
              Text(
                'Delivering to Seat 14C, Row 3',
                style: GoogleFonts.inter(
                  color: AppTheme.tertiary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 10),
              // Pill-shaped status chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'EST. 12 MIN',
                  style: GoogleFonts.inter(
                    color: AppTheme.accentGreen,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.05 * 9,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Category Filter ────────────────────────────────────────────────────────
  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (ctx, i) {
          final cat = _categories[i];
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.ctaGradient : null,
                  // Ghost style for unselected
                  border: isSelected
                      ? null
                      : Border.all(
                          color: AppTheme.outline.withOpacity(0.20),
                        ),
                  borderRadius: BorderRadius.circular(999), // pill shape
                ),
                child: Text(
                  cat,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected
                        ? AppTheme.onPrimary
                        : AppTheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Menu List ──────────────────────────────────────────────────────────────
  Widget _buildMenuList(BuildContext context, List<MenuItem> filteredItems) {
    return Container(
      // surfaceContainerLow parent so menu items (surfaceContainer) lift tonally
      color: AppTheme.surfaceContainerLow,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: filteredItems.length,
        itemBuilder: (ctx, i) => _MenuItemCard(
          item: filteredItems[i],
          onAdd: (item) {
            context.read<AppState>().addToCart(
                  CartItem(
                    id: item.id,
                    name: item.name,
                    price: item.price,
                    quantity: 1,
                    emoji: item.emoji,
                  ),
                );
          },
          onRemove: (item) {
            context.read<AppState>().removeFromCart(item.id);
          },
        ),
      ),
    );
  }

  // ── Cart FAB ───────────────────────────────────────────────────────────────
  Widget _buildCartFAB(BuildContext context) {
    return Consumer<AppState>(
      builder: (ctx, state, _) {
        if (state.cartItemCount == 0) return const SizedBox.shrink();

        return Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: GestureDetector(
            onTap: () => setState(() => _showCart = true),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                // Stitch CTA gradient — primary blue, not amber
                gradient: AppTheme.ctaGradient,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryContainer.withOpacity(0.30),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.20),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${state.cartItemCount}',
                      style: GoogleFonts.inter(
                        color: AppTheme.onPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'View Cart',
                    style: GoogleFonts.inter(
                      color: AppTheme.onPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '\$${state.cartTotal.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      color: AppTheme.onPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      color: AppTheme.onPrimary, size: 14),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isProcessing = false;

  // ── Cart Overlay (Glass) ───────────────────────────────────────────────────
  Widget _buildCartOverlay(BuildContext context, String? uid) {
    return _CartOverlay(
      isProcessing: _isProcessing,
      onClose: () => setState(() => _showCart = false),
      onCheckout: () async {
        setState(() => _isProcessing = true);
        try {
          await context.read<AppState>().placeOrder(uid);
          if (mounted) {
            setState(() {
              _isProcessing = false;
              _showCart = false;
              _orderPlaced = true;
            });
          }
        } catch (e) {
          if (mounted) setState(() => _isProcessing = false);
          debugPrint("UI Checkout Error: $e");
        }
      },
    );
  }

  // ── Success Screen ─────────────────────────────────────────────────────────
  Widget _buildSuccessScreen() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: AppTheme.ctaGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryContainer.withOpacity(0.35),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.check_rounded,
                    color: AppTheme.onPrimary, size: 48),
              ),
              const SizedBox(height: 28),
              Text(
                'Order Confirmed!',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.onSurface,
                  letterSpacing: -0.02 * 26,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your food is being prepared. Estimated delivery to Seat 14C is 12 minutes.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: AppTheme.onSurfaceVariant,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 12),
              // Pill status chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.tertiary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'ORDER #VV-4522',
                  style: GoogleFonts.inter(
                    color: AppTheme.tertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.05 * 11,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Ghost button — no fill
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () => setState(() => _orderPlaced = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppTheme.outline.withOpacity(0.20),
                      ),
                    ),
                    child: Text(
                      'Order More',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: AppTheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Menu Item Card ─────────────────────────────────────────────────────────────

class _MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final void Function(MenuItem) onAdd;
  final void Function(MenuItem) onRemove;

  const _MenuItemCard({
    required this.item,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final qty = context
            .watch<AppState>()
            .cart
            .where((c) => c.id == item.id)
            .firstOrNull
            ?.quantity ??
        0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Tonal lift — surfaceContainer on surfaceContainerLow parent
        // In-cart state: subtle primary tint (no border)
        color: qty > 0
            ? AppTheme.primary.withOpacity(0.08)
            : AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(4),
        // No explicit border per "No-Line" rule
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(item.emoji,
                  style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.inter(
                    color: AppTheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.description,
                  style: GoogleFonts.inter(
                    color: AppTheme.outline,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    color: AppTheme.tertiary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          qty == 0
              ? GestureDetector(
                  onTap: () => onAdd(item),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      gradient: AppTheme.ctaGradient,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    child: const Icon(Icons.add_rounded,
                        color: AppTheme.onPrimary, size: 20),
                  ),
                )
              : Row(
                  children: [
                    GestureDetector(
                      onTap: () => onRemove(item),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.remove_rounded,
                            color: AppTheme.primary, size: 16),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '$qty',
                        style: GoogleFonts.inter(
                          color: AppTheme.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => onAdd(item),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          gradient: AppTheme.ctaGradient,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        child: const Icon(Icons.add_rounded,
                            color: AppTheme.onPrimary, size: 16),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}

// ── Cart Overlay (GlassCard style bottom sheet) ────────────────────────────────

class _CartOverlay extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onCheckout;
  final bool isProcessing;

  const _CartOverlay({
    required this.onClose,
    required this.onCheckout,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black.withOpacity(0.60),
        child: GestureDetector(
          onTap: () {},
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.75,
                  ),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(4)),
                    border: Border.all(
                      color: AppTheme.outlineVariant.withOpacity(0.15),
                    ),
                  ),
                  child: Consumer<AppState>(
                    builder: (ctx, state, _) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Drag handle
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppTheme.outline.withOpacity(0.40),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Text(
                                'Your Cart',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.onSurface,
                                  letterSpacing: -0.02 * 20,
                                ),
                              ),
                              const Spacer(),
                              // Tertiary text-only button
                              GestureDetector(
                                onTap: state.clearCart,
                                child: Text(
                                  'Clear',
                                  style: GoogleFonts.inter(
                                    color: AppTheme.error,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Flexible(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: state.cart.length,
                              itemBuilder: (ctx, i) {
                                final item = state.cart[i];
                                return Padding(
                                  // 12px vertical whitespace — no Divider
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      Text(item.emoji,
                                          style:
                                              const TextStyle(fontSize: 22)),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          item.name,
                                          style: GoogleFonts.inter(
                                            color: AppTheme.onSurface,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'x${item.quantity}',
                                        style: GoogleFonts.inter(
                                          color: AppTheme.outline,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                        style: GoogleFonts.inter(
                                          color: AppTheme.tertiary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          // 20px spacing instead of Divider
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: GoogleFonts.inter(
                                  color: AppTheme.onSurfaceVariant,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                '\$${state.cartTotal.toStringAsFixed(2)}',
                                style: GoogleFonts.inter(
                                  color: AppTheme.onSurface,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                  letterSpacing: -0.02 * 20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // CTA gradient checkout button
                          SizedBox(
                            width: double.infinity,
                            child: GestureDetector(
                              onTap: onCheckout,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16),
                                decoration: const BoxDecoration(
                                  gradient: AppTheme.ctaGradient,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
                                ),
                                child: isProcessing
                                    ? const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppTheme.onPrimary,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        'Place Order – \$${state.cartTotal.toStringAsFixed(2)}',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.inter(
                                          color: AppTheme.onPrimary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
