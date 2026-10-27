import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_text_field.dart';
import '../../core/utils/currency_format.dart';
import '../../core/utils/date_format.dart';
import '../../core/utils/whatsapp_helper.dart';
import '../../models/invoice_model.dart';
import '../../state/app_state.dart';
import 'pdf_preview_screen.dart';
import 'create_invoice_screen.dart';

class InvoiceListScreen extends StatefulWidget {
  final AppState appState;

  const InvoiceListScreen({super.key, required this.appState});

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<InvoiceModel> get _filteredInvoices {
    final query = _searchController.text.trim().toLowerCase();
    return widget.appState.invoices.where((inv) {
      final matchesQuery = query.isEmpty ||
          inv.invoiceNumber.toLowerCase().contains(query) ||
          inv.customer.name.toLowerCase().contains(query) ||
          inv.customer.phone.contains(query);

      final matchesFilter = _selectedFilter == 'All' ||
          inv.paymentStatus.toLowerCase() == _selectedFilter.toLowerCase();

      return matchesQuery && matchesFilter;
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppColors.statusPaid;
      case 'partial':
        return AppColors.statusPending;
      case 'unpaid':
        return AppColors.statusDue;
      default:
        return AppColors.goldPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredInvoices;

    return GlassScaffold(
      appBar: AppBar(
        title: const Text(
          'Invoice Records',
          style: TextStyle(
            color: AppColors.goldLight,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppColors.goldPrimary, size: 28),
            tooltip: 'Create New Invoice',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateInvoiceScreen(appState: widget.appState),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                GlassTextField(
                  controller: _searchController,
                  hint: 'Search by Invoice #, Customer or Phone...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.goldPrimary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.textMuted, size: 18),
                          onPressed: () {
                            setState(() => _searchController.clear());
                          },
                        )
                      : null,
                  onChanged: (val) => setState(() {}),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Paid', 'Partial', 'Unpaid'].map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          selectedColor: AppColors.goldPrimary,
                          backgroundColor: AppColors.glassWhite,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _selectedFilter = filter);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Invoices List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textMuted),
                        const SizedBox(height: 16),
                        Text(
                          widget.appState.invoices.isEmpty
                              ? 'No invoices created yet'
                              : 'No matching invoices found',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateInvoiceScreen(appState: widget.appState),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add, color: Colors.black),
                          label: const Text('Create First Invoice', style: TextStyle(color: Colors.black)),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldPrimary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final inv = filtered[index];
                      final statusColor = _getStatusColor(inv.paymentStatus);

                      return GlassCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PdfPreviewScreen(
                                invoice: inv,
                                business: widget.appState.businessProfile,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row: Invoice # and Payment Status Badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.wineAccent.withValues(alpha: 0.35),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: AppColors.glassBorderGold),
                                      ),
                                      child: const Icon(
                                        Icons.receipt,
                                        size: 16,
                                        color: AppColors.goldPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '#${inv.invoiceNumber}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          DateHelper.formatWithTime(inv.date),
                                          style: const TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: statusColor, width: 1),
                                  ),
                                  child: Text(
                                    inv.paymentStatus.toUpperCase(),
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Divider(color: AppColors.glassBorder, height: 18),

                            // Customer & Item details
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      inv.customer.name,
                                      style: const TextStyle(
                                        color: AppColors.goldLight,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${inv.items.length} items • ${inv.paymentMode}',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  CurrencyHelper.format(inv.grandTotal),
                                  style: const TextStyle(
                                    color: AppColors.goldLight,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Quick Action Buttons (WhatsApp & PDF View)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {
                                    WhatsAppHelper.sendWhatsAppMessage(
                                      invoice: inv,
                                      business: widget.appState.businessProfile,
                                    );
                                  },
                                  icon: const Icon(Icons.chat, color: AppColors.whatsappGreen, size: 16),
                                  label: const Text(
                                    'WhatsApp',
                                    style: TextStyle(color: AppColors.whatsappGreen, fontSize: 12),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.whatsappGreen),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PdfPreviewScreen(
                                          invoice: inv,
                                          business: widget.appState.businessProfile,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.picture_as_pdf, color: Colors.black, size: 16),
                                  label: const Text(
                                    'View PDF',
                                    style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.goldPrimary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
