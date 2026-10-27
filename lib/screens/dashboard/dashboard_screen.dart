import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/utils/currency_format.dart';
import '../../core/utils/date_format.dart';
import '../../core/utils/whatsapp_helper.dart';
import '../../state/app_state.dart';
import '../invoice/create_invoice_screen.dart';
import '../invoice/pdf_preview_screen.dart';

class DashboardScreen extends StatelessWidget {
  final AppState appState;
  final ValueChanged<int>? onNavigateTab;

  const DashboardScreen({
    super.key,
    required this.appState,
    this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Brand Header Bar
                _buildHeader(context),
                const SizedBox(height: 20),

                // Primary Quick Action Banner
                _buildQuickActionBanner(context),
                const SizedBox(height: 20),

                // Stat Cards Grid
                _buildStatCardsGrid(),
                const SizedBox(height: 20),

                // Sales Trend Chart Card
                _buildSalesChartCard(),
                const SizedBox(height: 20),

                // Top Selling Beauty Products Section
                _buildTopSellingSection(context),
                const SizedBox(height: 20),

                // Recent Invoices List
                _buildRecentInvoicesSection(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hasGoldBorder: true,
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.goldPrimary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.goldPrimary.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
              image: const DecorationImage(
                image: AssetImage('assets/images/logo_round.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appState.businessProfile.businessName.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.goldLight,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                Text(
                  'Owner: ${appState.businessProfile.ownerName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  DateHelper.format(DateTime.now()),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // Live Cloud Sync Status Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: appState.firebaseService.isEnabled
                  ? AppColors.statusPaid.withValues(alpha: 0.2)
                  : AppColors.glassWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: appState.firebaseService.isEnabled
                    ? AppColors.statusPaid
                    : AppColors.glassBorderGold,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  appState.firebaseService.isEnabled ? Icons.cloud_done : Icons.cloud_outlined,
                  size: 13,
                  color: appState.firebaseService.isEnabled ? AppColors.statusPaid : AppColors.goldLight,
                ),
                const SizedBox(width: 4),
                Text(
                  appState.firebaseService.isEnabled ? 'Live Cloud' : 'Offline Ready',
                  style: TextStyle(
                    color: appState.firebaseService.isEnabled ? AppColors.statusPaid : AppColors.goldLight,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionBanner(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: AppColors.goldGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.goldPrimary.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateInvoiceScreen(appState: appState),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.wineDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.add_shopping_cart,
                    color: AppColors.goldLight,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create New Invoice',
                        style: TextStyle(
                          color: Color(0xFF230D03),
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Bill products, auto-save & send WhatsApp receipt',
                        style: TextStyle(
                          color: Color(0xFF4C270A),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF230D03),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCardsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: "Today's Sales",
                value: CurrencyHelper.format(appState.todaySales),
                icon: Icons.today,
                subtitle: "Daily",
                iconGradient: AppColors.wineGradient,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: "Month's Sales",
                value: CurrencyHelper.format(appState.thisMonthSales),
                icon: Icons.calendar_month,
                subtitle: "Monthly",
                iconGradient: AppColors.goldGradient,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: "Total Invoices",
                value: '${appState.totalInvoicesCount}',
                icon: Icons.receipt_long,
                subtitle: "Billed",
                iconGradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: "Pending Dues",
                value: CurrencyHelper.format(appState.totalPendingDue),
                icon: Icons.pending_actions,
                subtitle: appState.totalPendingDue > 0 ? "Collect" : "Clear",
                iconColor: AppColors.statusDue,
                iconGradient: const LinearGradient(
                  colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSalesChartCard() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Revenue Overview',
                style: TextStyle(
                  color: AppColors.goldLight,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Last 7 Days',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (val, meta) {
                        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        final idx = val.toInt() % 7;
                        return Text(
                          days[idx],
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 1800),
                      FlSpot(1, 3200),
                      FlSpot(2, 2400),
                      FlSpot(3, 4900),
                      FlSpot(4, 3800),
                      FlSpot(5, 7500),
                      FlSpot(6, 6200),
                    ],
                    isCurved: true,
                    gradient: AppColors.goldGradient,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.goldPrimary.withValues(alpha: 0.35),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSellingSection(BuildContext context) {
    final topProducts = appState.topSellingProducts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Popular Products & Treatments',
              style: TextStyle(
                color: AppColors.goldLight,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (onNavigateTab != null)
              TextButton(
                onPressed: () => onNavigateTab!(3), // Product tab
                child: const Text('View All', style: TextStyle(color: AppColors.goldPrimary, fontSize: 12)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: topProducts.length,
            itemBuilder: (context, index) {
              final product = topProducts[index];
              return Container(
                width: 170,
                margin: const EdgeInsets.only(right: 12),
                child: GlassCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        product.category,
                        style: const TextStyle(color: AppColors.goldLight, fontSize: 10),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            CurrencyHelper.format(product.price),
                            style: const TextStyle(
                              color: AppColors.goldLight,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateInvoiceScreen(
                                    appState: appState,
                                    initialProduct: product,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.wineAccent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.add, color: Colors.white, size: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentInvoicesSection(BuildContext context) {
    final recent = appState.recentInvoices;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Invoices',
              style: TextStyle(
                color: AppColors.goldLight,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (onNavigateTab != null)
              TextButton(
                onPressed: () => onNavigateTab!(1), // Invoices tab
                child: const Text('See All', style: TextStyle(color: AppColors.goldPrimary, fontSize: 12)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (recent.isEmpty)
          const GlassCard(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text(
                'No invoices created yet. Tap "Create New Invoice" to start billing!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
          )
        else
          ...recent.map((inv) {
            return GlassCard(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PdfPreviewScreen(
                      invoice: inv,
                      business: appState.businessProfile,
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.winePrimary.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.glassBorderGold),
                    ),
                    child: const Icon(Icons.receipt, color: AppColors.goldLight, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${inv.invoiceNumber} • ${inv.customer.name}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateHelper.formatWithTime(inv.date),
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyHelper.format(inv.grandTotal),
                        style: const TextStyle(
                          color: AppColors.goldLight,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chat, color: AppColors.whatsappGreen, size: 18),
                            onPressed: () {
                              WhatsAppHelper.sendWhatsAppMessage(
                                invoice: inv,
                                business: appState.businessProfile,
                              );
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.picture_as_pdf, color: AppColors.goldPrimary, size: 18),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PdfPreviewScreen(
                                    invoice: inv,
                                    business: appState.businessProfile,
                                  ),
                                ),
                              );
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
