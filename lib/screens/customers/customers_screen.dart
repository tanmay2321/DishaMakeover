import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_text_field.dart';
import '../../core/utils/currency_format.dart';
import '../../core/utils/date_format.dart';
import '../../models/customer_model.dart';
import '../../state/app_state.dart';

class CustomersScreen extends StatefulWidget {
  final AppState appState;

  const CustomersScreen({super.key, required this.appState});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CustomerModel> get _filteredCustomers {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return widget.appState.customers;
    return widget.appState.customers.where((c) {
      return c.name.toLowerCase().contains(query) || c.phone.contains(query);
    }).toList();
  }

  void _callPhone(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openWhatsApp(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customers = _filteredCustomers;

    return GlassScaffold(
      appBar: AppBar(
        title: const Text(
          'Customer Directory',
          style: TextStyle(
            color: AppColors.goldLight,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GlassTextField(
              controller: _searchController,
              hint: 'Search by customer name or phone...',
              prefixIcon: const Icon(Icons.search, color: AppColors.goldPrimary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textMuted, size: 18),
                      onPressed: () => setState(() => _searchController.clear()),
                    )
                  : null,
              onChanged: (val) => setState(() {}),
            ),
          ),
          Expanded(
            child: customers.isEmpty
                ? const Center(
                    child: Text(
                      'No customers found',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      return GlassCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: AppColors.wineAccent,
                                      child: Text(
                                        customer.name.isNotEmpty
                                            ? customer.name[0].toUpperCase()
                                            : 'C',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          customer.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          customer.phone,
                                          style: const TextStyle(
                                            color: AppColors.goldLight,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      CurrencyHelper.format(customer.totalSpent),
                                      style: const TextStyle(
                                        color: AppColors.goldLight,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '${customer.totalInvoices} visit(s)',
                                      style: const TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (customer.address.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: AppColors.textMuted, size: 14),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      customer.address,
                                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 6),
                            Text(
                              'Last visit: ${DateHelper.format(customer.lastVisit)}',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                            ),
                            const Divider(color: AppColors.glassBorder, height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _callPhone(customer.phone),
                                  icon: const Icon(Icons.phone, color: AppColors.goldPrimary, size: 16),
                                  label: const Text('Call', style: TextStyle(color: AppColors.goldPrimary, fontSize: 12)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.goldPrimary),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () => _openWhatsApp(customer.phone),
                                  icon: const Icon(Icons.chat, color: Colors.white, size: 16),
                                  label: const Text('WhatsApp', style: TextStyle(color: Colors.white, fontSize: 12)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.whatsappGreen,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
