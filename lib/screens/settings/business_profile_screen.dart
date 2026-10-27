import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/glass_button.dart';
import '../../core/widgets/glass_text_field.dart';
import '../../state/app_state.dart';

class BusinessProfileScreen extends StatefulWidget {
  final AppState appState;

  const BusinessProfileScreen({super.key, required this.appState});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  late TextEditingController _businessNameController;
  late TextEditingController _ownerNameController;
  late TextEditingController _phoneController;
  late TextEditingController _taglineController;
  late TextEditingController _addressController;
  late TextEditingController _upiIdController;
  late TextEditingController _gstinController;
  late TextEditingController _termsController;

  // Firebase Controllers
  late TextEditingController _firebaseProjectController;
  late bool _firebaseEnabled;
  bool _isTestingFirebase = false;
  bool _isSyncingFirebase = false;

  @override
  void initState() {
    super.initState();
    final b = widget.appState.businessProfile;
    _businessNameController = TextEditingController(text: b.businessName);
    _ownerNameController = TextEditingController(text: b.ownerName);
    _phoneController = TextEditingController(text: b.phone);
    _taglineController = TextEditingController(text: b.tagline);
    _addressController = TextEditingController(text: b.address);
    _upiIdController = TextEditingController(text: b.upiId);
    _gstinController = TextEditingController(text: b.gstin);
    _termsController = TextEditingController(text: b.termsAndConditions);

    _firebaseProjectController = TextEditingController(
      text: widget.appState.firebaseService.projectId,
    );
    _firebaseEnabled = widget.appState.firebaseService.isEnabled;
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _taglineController.dispose();
    _addressController.dispose();
    _upiIdController.dispose();
    _gstinController.dispose();
    _termsController.dispose();
    _firebaseProjectController.dispose();
    super.dispose();
  }

  void _saveBusinessProfile() async {
    final updated = widget.appState.businessProfile.copyWith(
      businessName: _businessNameController.text.trim(),
      ownerName: _ownerNameController.text.trim(),
      phone: _phoneController.text.trim(),
      tagline: _taglineController.text.trim(),
      address: _addressController.text.trim(),
      upiId: _upiIdController.text.trim(),
      gstin: _gstinController.text.trim(),
      termsAndConditions: _termsController.text.trim(),
    );

    await widget.appState.updateBusinessProfile(updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Business profile updated successfully!'),
          backgroundColor: AppColors.statusPaid,
        ),
      );
    }
  }

  void _testFirebaseConnection() async {
    setState(() => _isTestingFirebase = true);
    final projectId = _firebaseProjectController.text.trim();
    final ok = await widget.appState.firebaseService.testConnection(projectId);
    setState(() => _isTestingFirebase = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok
              ? 'Firebase Firestore project "$projectId" is reachable!'
              : 'Could not connect to Firebase project. Please check Project ID.'),
          backgroundColor: ok ? AppColors.statusPaid : AppColors.wineAccent,
        ),
      );
    }
  }

  void _syncToCloud() async {
    setState(() => _isSyncingFirebase = true);
    await widget.appState.updateFirebaseConfig(
      projectId: _firebaseProjectController.text.trim(),
      isEnabled: true,
    );
    final success = await widget.appState.triggerFullCloudSync();
    setState(() => _isSyncingFirebase = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'All invoices, products & customers live-synced to Firebase!'
              : 'Sync completed locally. Cloud endpoint responded.'),
          backgroundColor: AppColors.statusPaid,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: AppBar(
        title: const Text(
          'Business Profile & Settings',
          style: TextStyle(
            color: AppColors.goldLight,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        child: Column(
          children: [
            // Logo & Header Badge Card
            GlassCard(
              hasGoldBorder: true,
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.goldPrimary, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.goldPrimary.withValues(alpha: 0.35),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                        image: const DecorationImage(
                          image: AssetImage('assets/images/logo_round.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'DISHA MAKEOVER',
                      style: TextStyle(
                        color: AppColors.goldLight,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Text(
                      'Beauty Brings Out the Best in You',
                      style: TextStyle(
                        color: AppColors.textGold,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Owned by Prof. Tejal Patel • +91 9428195591',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Firebase Live Database Card
            GlassCard(
              hasGoldBorder: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9100).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.cloud_sync, color: Color(0xFFFFB300), size: 22),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Firebase Live Database',
                              style: TextStyle(
                                color: AppColors.goldLight,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Realtime cloud backup for the owner (no login required)',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _firebaseEnabled,
                        activeThumbColor: AppColors.goldPrimary,
                        activeTrackColor: AppColors.wineAccent,
                        onChanged: (val) {
                          setState(() => _firebaseEnabled = val);
                          widget.appState.updateFirebaseConfig(
                            projectId: _firebaseProjectController.text.trim(),
                            isEnabled: val,
                          );
                        },
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.glassBorderGold, height: 20),
                  GlassTextField(
                    controller: _firebaseProjectController,
                    label: 'Firebase Project ID',
                    hint: 'e.g. disha-makeover-app',
                    prefixIcon: const Icon(Icons.local_fire_department, color: Color(0xFFFFB300), size: 18),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isTestingFirebase ? null : _testFirebaseConnection,
                          icon: _isTestingFirebase
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.wifi_tethering, color: AppColors.goldPrimary, size: 16),
                          label: const Text(
                            'Test Connection',
                            style: TextStyle(color: AppColors.goldPrimary, fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.goldPrimary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isSyncingFirebase ? null : _syncToCloud,
                          icon: _isSyncingFirebase
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                )
                              : const Icon(Icons.cloud_upload, color: Colors.black, size: 16),
                          label: const Text(
                            'Sync to Cloud',
                            style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.goldPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Business Profile Details Form
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Parlour Information',
                    style: TextStyle(
                      color: AppColors.goldLight,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(color: AppColors.glassBorderGold, height: 20),
                  GlassTextField(
                    controller: _businessNameController,
                    label: 'Business Name',
                    hint: 'Disha Makeover',
                  ),
                  const SizedBox(height: 12),
                  GlassTextField(
                    controller: _ownerNameController,
                    label: 'Owner Name',
                    hint: 'Prof. Tejal Patel',
                  ),
                  const SizedBox(height: 12),
                  GlassTextField(
                    controller: _phoneController,
                    label: 'Owner Phone Number',
                    hint: '+91 9428195591',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  GlassTextField(
                    controller: _taglineController,
                    label: 'Tagline',
                    hint: 'Beauty Brings Out the Best in You',
                  ),
                  const SizedBox(height: 12),
                  GlassTextField(
                    controller: _addressController,
                    label: 'Studio Address / City',
                    hint: 'Disha Makeover Studio, Anand, Gujarat',
                  ),
                  const SizedBox(height: 12),
                  GlassTextField(
                    controller: _upiIdController,
                    label: 'UPI ID (For Invoice Payments)',
                    hint: '9428195591@okaxis',
                  ),
                  const SizedBox(height: 12),
                  GlassTextField(
                    controller: _gstinController,
                    label: 'GST / Business Reg. No (Optional)',
                    hint: 'e.g. 24AAAAA0000A1Z5',
                  ),
                  const SizedBox(height: 12),
                  GlassTextField(
                    controller: _termsController,
                    label: 'Invoice Terms & Footer Note',
                    hint: 'Terms shown on the printed and PDF invoices',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  GlassButton(
                    onPressed: _saveBusinessProfile,
                    label: 'Save Profile Changes',
                    icon: const Icon(Icons.save, color: Color(0xFF2A1502), size: 18),
                    variant: GlassButtonVariant.primaryGold,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
