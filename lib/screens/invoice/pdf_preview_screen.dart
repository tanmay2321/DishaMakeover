import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/glass_button.dart';
import '../../core/utils/whatsapp_helper.dart';
import '../../models/business_profile_model.dart';
import '../../models/invoice_model.dart';
import '../../services/pdf_invoice_service.dart';

class PdfPreviewScreen extends StatefulWidget {
  final InvoiceModel invoice;
  final BusinessProfileModel business;

  const PdfPreviewScreen({
    super.key,
    required this.invoice,
    required this.business,
  });

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  bool _isSharing = false;

  Future<void> _shareOnWhatsApp() async {
    setState(() => _isSharing = true);
    try {
      final pdfBytes = await PdfInvoiceService.generateInvoicePdf(
        invoice: widget.invoice,
        business: widget.business,
      );
      final filePath = await PdfInvoiceService.savePdfToFile(
        bytes: pdfBytes,
        invoiceNumber: widget.invoice.invoiceNumber,
      );

      await WhatsAppHelper.sharePdfWithWhatsAppText(
        pdfFilePath: filePath,
        invoice: widget.invoice,
        business: widget.business,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing invoice: $e'),
            backgroundColor: AppColors.wineAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<void> _sendDirectWhatsApp() async {
    final success = await WhatsAppHelper.sendWhatsAppMessage(
      invoice: widget.invoice,
      business: widget.business,
    );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not launch WhatsApp. Check if customer phone number is valid.'),
          backgroundColor: AppColors.wineAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: AppBar(
        title: Text(
          'Invoice #${widget.invoice.invoiceNumber}',
          style: const TextStyle(
            color: AppColors.goldLight,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.send_rounded, color: AppColors.whatsappGreen),
            tooltip: 'Send WhatsApp Message',
            onPressed: _sendDirectWhatsApp,
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppColors.goldPrimary),
            tooltip: 'Share PDF',
            onPressed: _shareOnWhatsApp,
          ),
        ],
      ),
      body: Column(
        children: [
          // Action Bar for Quick WhatsApp Sharing
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: GlassButton(
                    onPressed: _sendDirectWhatsApp,
                    label: 'WhatsApp Text',
                    icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 18),
                    variant: GlassButtonVariant.whatsapp,
                    height: 44,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GlassButton(
                    onPressed: _shareOnWhatsApp,
                    label: 'Share PDF File',
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 18),
                    variant: GlassButtonVariant.primaryWine,
                    isLoading: _isSharing,
                    height: 44,
                  ),
                ),
              ],
            ),
          ),
          // PDF Preview Area
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: PdfPreview(
                build: (format) => PdfInvoiceService.generateInvoicePdf(
                  invoice: widget.invoice,
                  business: widget.business,
                ),
                canChangePageFormat: false,
                canChangeOrientation: false,
                canDebug: false,
                allowSharing: true,
                allowPrinting: true,
                pdfFileName: 'DishaMakeover_${widget.invoice.invoiceNumber}.pdf',
                previewPageMargin: const EdgeInsets.all(12),
                actions: [
                  PdfPreviewAction(
                    icon: const Icon(Icons.send, color: AppColors.whatsappGreen),
                    onPressed: (context, build, page) async => _sendDirectWhatsApp(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
