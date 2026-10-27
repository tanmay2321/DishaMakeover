import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../state/app_state.dart';
import 'dashboard/dashboard_screen.dart';
import 'invoice/invoice_list_screen.dart';
import 'invoice/create_invoice_screen.dart';
import 'catalog/product_catalog_screen.dart';
import 'customers/customers_screen.dart';
import 'settings/business_profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final AppState appState;

  const MainNavigationScreen({super.key, required this.appState});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(
        appState: widget.appState,
        onNavigateTab: (index) => setState(() => _currentIndex = index),
      ),
      InvoiceListScreen(appState: widget.appState),
      CreateInvoiceScreen(appState: widget.appState),
      ProductCatalogScreen(appState: widget.appState),
      CustomersScreen(appState: widget.appState),
      BusinessProfileScreen(appState: widget.appState),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildGlassBottomBar(),
    );
  }

  Widget _buildGlassBottomBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppColors.goldPrimary.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.bgSurface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.glassBorderGold, width: 1.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.dashboard_outlined, Icons.dashboard, 'Home'),
                _buildNavItem(1, Icons.receipt_long_outlined, Icons.receipt_long, 'Bills'),
                _buildCenterBillingButton(),
                _buildNavItem(3, Icons.spa_outlined, Icons.spa, 'Catalog'),
                _buildNavItem(4, Icons.people_outline, Icons.people, 'Clients'),
                _buildNavItem(5, Icons.storefront_outlined, Icons.storefront, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData unselectedIcon, IconData selectedIcon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : unselectedIcon,
              color: isSelected ? AppColors.goldLight : AppColors.textMuted,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.goldLight : AppColors.textMuted,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 14,
                height: 2.5,
                decoration: BoxDecoration(
                  color: AppColors.goldPrimary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterBillingButton() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.goldGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.goldPrimary.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.add_shopping_cart, color: Color(0xFF230D03), size: 22),
        tooltip: 'Create Invoice',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateInvoiceScreen(appState: widget.appState),
            ),
          );
        },
      ),
    );
  }
}
