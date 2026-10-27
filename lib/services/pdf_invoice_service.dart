import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/business_profile_model.dart';
import '../models/invoice_model.dart';
import '../core/utils/date_format.dart';

class PdfInvoiceService {
  // Brand colors for PDF printing
  static const PdfColor pdfWinePrimary = PdfColor.fromInt(0xFF800C36);
  static const PdfColor pdfWineDark = PdfColor.fromInt(0xFF4A081E);
  static const PdfColor pdfGoldPrimary = PdfColor.fromInt(0xFFC59B27);
  static const PdfColor pdfGoldLight = PdfColor.fromInt(0xFFFBF4DB);
  static const PdfColor pdfGrayDark = PdfColor.fromInt(0xFF333333);
  static const PdfColor pdfGrayLight = PdfColor.fromInt(0xFFF9F9F9);
  static const PdfColor pdfGreen = PdfColor.fromInt(0xFF10B981);

  static Future<Uint8List> generateInvoicePdf({
    required InvoiceModel invoice,
    required BusinessProfileModel business,
  }) async {
    final pdf = pw.Document();

    // Load logo image
    pw.MemoryImage? logoImage;
    try {
      final ByteData data = await rootBundle.load('assets/images/logo_round.jpg');
      logoImage = pw.MemoryImage(data.buffer.asUint8List());
    } catch (e) {
      // Fallback if image asset loading fails
    }

    final ttfBold = await PdfGoogleFonts.poppinsSemiBold();
    final ttfRegular = await PdfGoogleFonts.poppinsRegular();
    final ttfItalic = await PdfGoogleFonts.playfairDisplayItalic();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Top Brand Header Bar
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: pdfWineDark,
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    if (logoImage != null)
                      pw.Container(
                        width: 75,
                        height: 75,
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          border: pw.Border.all(color: pdfGoldPrimary, width: 2),
                          image: pw.DecorationImage(
                            image: logoImage,
                            fit: pw.BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      pw.Container(
                        width: 65,
                        height: 65,
                        decoration: const pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          color: pdfGoldPrimary,
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            'DM',
                            style: pw.TextStyle(
                              font: ttfBold,
                              fontSize: 22,
                              color: PdfColors.white,
                            ),
                          ),
                        ),
                      ),
                    pw.SizedBox(width: 16),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            business.businessName.toUpperCase(),
                            style: pw.TextStyle(
                              font: ttfBold,
                              fontSize: 24,
                              color: pdfGoldLight,
                              letterSpacing: 1.2,
                            ),
                          ),
                          pw.Text(
                            business.tagline,
                            style: pw.TextStyle(
                              font: ttfItalic,
                              fontSize: 11,
                              color: pdfGoldPrimary,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Prop: ${business.ownerName}  |  Ph: ${business.phone}',
                            style: pw.TextStyle(
                              font: ttfRegular,
                              fontSize: 10,
                              color: PdfColors.white,
                            ),
                          ),
                          if (business.address.isNotEmpty)
                            pw.Text(
                              business.address,
                              style: pw.TextStyle(
                                font: ttfRegular,
                                fontSize: 9,
                                color: PdfColors.grey300,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Invoice Badge Box
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: pw.BoxDecoration(
                        color: pdfGoldPrimary,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'TAX INVOICE',
                            style: pw.TextStyle(
                              font: ttfBold,
                              fontSize: 12,
                              color: pdfWineDark,
                            ),
                          ),
                          pw.Text(
                            '#${invoice.invoiceNumber}',
                            style: pw.TextStyle(
                              font: ttfBold,
                              fontSize: 13,
                              color: PdfColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 18),

              // Invoice Details & Bill To Row
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  // Bill To Customer
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: pw.BorderRadius.circular(8),
                        color: pdfGrayLight,
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'BILLED TO:',
                            style: pw.TextStyle(
                              font: ttfBold,
                              fontSize: 9,
                              color: pdfWinePrimary,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            invoice.customer.name,
                            style: pw.TextStyle(
                              font: ttfBold,
                              fontSize: 14,
                              color: pdfGrayDark,
                            ),
                          ),
                          pw.Text(
                            'Phone: ${invoice.customer.phone}',
                            style: pw.TextStyle(
                              font: ttfRegular,
                              fontSize: 10,
                              color: PdfColors.grey700,
                            ),
                          ),
                          if (invoice.customer.address.isNotEmpty)
                            pw.Text(
                              'Address: ${invoice.customer.address}',
                              style: pw.TextStyle(
                                font: ttfRegular,
                                fontSize: 9,
                                color: PdfColors.grey700,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 16),
                  // Invoice Metadata
                  pw.Container(
                    width: 200,
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: pw.BorderRadius.circular(8),
                      color: pdfGrayLight,
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildMetaRow('Date:', DateHelper.format(invoice.date), ttfBold, ttfRegular),
                        _buildMetaRow('Status:', invoice.paymentStatus.toUpperCase(), ttfBold, ttfBold,
                            valueColor: invoice.paymentStatus.toLowerCase() == 'paid' ? pdfGreen : pdfWinePrimary),
                        _buildMetaRow('Payment Mode:', invoice.paymentMode, ttfBold, ttfRegular),
                        if (business.gstin.isNotEmpty)
                          _buildMetaRow('GSTIN:', business.gstin, ttfBold, ttfRegular),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 18),

              // Items Table
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: pdfGoldPrimary, width: 0.8),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Table(
                  border: const pw.TableBorder(
                    horizontalInside: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
                  ),
                  columnWidths: {
                    0: const pw.FixedColumnWidth(30),
                    1: const pw.FlexColumnWidth(4),
                    2: const pw.FlexColumnWidth(2),
                    3: const pw.FlexColumnWidth(1.5),
                    4: const pw.FixedColumnWidth(40),
                    5: const pw.FlexColumnWidth(1.8),
                  },
                  children: [
                    // Header Row
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: pdfWineDark),
                      children: [
                        _buildTableHeader('#', ttfBold),
                        _buildTableHeader('Item / Service Name', ttfBold),
                        _buildTableHeader('Category', ttfBold),
                        _buildTableHeader('Rate (Rs)', ttfBold, align: pw.TextAlign.right),
                        _buildTableHeader('Qty', ttfBold, align: pw.TextAlign.center),
                        _buildTableHeader('Amount (Rs)', ttfBold, align: pw.TextAlign.right),
                      ],
                    ),
                    // Item Rows
                    ...invoice.items.asMap().entries.map((entry) {
                      final i = entry.key;
                      final item = entry.value;
                      final isEven = i % 2 == 0;
                      return pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: isEven ? PdfColors.white : pdfGrayLight,
                        ),
                        children: [
                          _buildTableCell('${i + 1}', ttfRegular, align: pw.TextAlign.center),
                          _buildTableCell(item.name, ttfBold),
                          _buildTableCell(item.category, ttfRegular),
                          _buildTableCell(
                            item.unitPrice.toStringAsFixed(2),
                            ttfRegular,
                            align: pw.TextAlign.right,
                          ),
                          _buildTableCell('${item.quantity}', ttfRegular, align: pw.TextAlign.center),
                          _buildTableCell(
                            item.total.toStringAsFixed(2),
                            ttfBold,
                            align: pw.TextAlign.right,
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),

              pw.SizedBox(height: 16),

              // Totals and Payment Summary Section
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left: Terms & UPI Details
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: pdfGrayLight,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          if (business.upiId.isNotEmpty) ...[
                            pw.Text(
                              'Payment Info (UPI / GPay):',
                              style: pw.TextStyle(font: ttfBold, fontSize: 9, color: pdfWinePrimary),
                            ),
                            pw.Text(
                              business.upiId,
                              style: pw.TextStyle(font: ttfBold, fontSize: 10, color: pdfGrayDark),
                            ),
                            pw.SizedBox(height: 6),
                          ],
                          pw.Text(
                            'Terms & Conditions:',
                            style: pw.TextStyle(font: ttfBold, fontSize: 8, color: pdfGrayDark),
                          ),
                          pw.Text(
                            business.termsAndConditions,
                            style: pw.TextStyle(font: ttfRegular, fontSize: 7.5, color: PdfColors.grey700),
                          ),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  // Right: Total Calculation Box
                  pw.Container(
                    width: 220,
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: pdfGoldLight,
                      borderRadius: pw.BorderRadius.circular(8),
                      border: pw.Border.all(color: pdfGoldPrimary, width: 1),
                    ),
                    child: pw.Column(
                      children: [
                        _buildSummaryRow('Subtotal:', 'Rs ${invoice.subtotal.toStringAsFixed(2)}', ttfRegular, ttfRegular),
                        if (invoice.discountAmount > 0)
                          _buildSummaryRow(
                            'Discount:',
                            '- Rs ${invoice.discountAmount.toStringAsFixed(2)}',
                            ttfRegular,
                            ttfRegular,
                            valueColor: pdfWinePrimary,
                          ),
                        if (invoice.taxAmount > 0)
                          _buildSummaryRow(
                            'GST (${invoice.taxPercentage.toInt()}%):',
                            '+ Rs ${invoice.taxAmount.toStringAsFixed(2)}',
                            ttfRegular,
                            ttfRegular,
                          ),
                        pw.Divider(color: pdfGoldPrimary, thickness: 1),
                        _buildSummaryRow(
                          'GRAND TOTAL:',
                          'Rs ${invoice.grandTotal.toStringAsFixed(2)}',
                          ttfBold,
                          ttfBold,
                          fontSize: 13,
                          valueColor: pdfWineDark,
                        ),
                        if (invoice.amountPaid > 0 && invoice.paymentStatus.toLowerCase() != 'paid') ...[
                          pw.SizedBox(height: 4),
                          _buildSummaryRow('Amount Paid:', 'Rs ${invoice.amountPaid.toStringAsFixed(2)}', ttfRegular, ttfRegular),
                          _buildSummaryRow(
                            'Balance Due:',
                            'Rs ${invoice.balanceDue.toStringAsFixed(2)}',
                            ttfBold,
                            ttfBold,
                            valueColor: pdfWinePrimary,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // Footer & Signatory
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Thank you for your visit!',
                        style: pw.TextStyle(font: ttfBold, fontSize: 11, color: pdfWinePrimary),
                      ),
                      pw.Text(
                        'Beauty Brings Out the Best in You',
                        style: pw.TextStyle(font: ttfItalic, fontSize: 10, color: pdfGoldPrimary),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'Prof. Tejal Patel',
                        style: pw.TextStyle(font: ttfItalic, fontSize: 13, color: pdfWineDark),
                      ),
                      pw.Container(
                        width: 140,
                        height: 1,
                        color: pdfWineDark,
                        margin: const pw.EdgeInsets.symmetric(vertical: 4),
                      ),
                      pw.Text(
                        'Authorized Signatory',
                        style: pw.TextStyle(font: ttfRegular, fontSize: 8, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildTableHeader(String text, pw.Font font, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(font: font, fontSize: 9.5, color: pdfGoldLight),
      ),
    );
  }

  static pw.Widget _buildTableCell(String text, pw.Font font, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(font: font, fontSize: 9, color: pdfGrayDark),
      ),
    );
  }

  static pw.Widget _buildMetaRow(String label, String value, pw.Font labelFont, pw.Font valFont, {PdfColor? valueColor}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: labelFont, fontSize: 9, color: pdfGrayDark)),
          pw.Text(value, style: pw.TextStyle(font: valFont, fontSize: 9.5, color: valueColor ?? pdfGrayDark)),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryRow(
    String label,
    String value,
    pw.Font labelFont,
    pw.Font valFont, {
    double fontSize = 10,
    PdfColor? valueColor,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: labelFont, fontSize: fontSize, color: pdfWineDark)),
          pw.Text(value, style: pw.TextStyle(font: valFont, fontSize: fontSize, color: valueColor ?? pdfWineDark)),
        ],
      ),
    );
  }

  /// Saves generated PDF bytes to file and returns path
  static Future<String> savePdfToFile({
    required Uint8List bytes,
    required String invoiceNumber,
  }) async {
    final outputDir = await getApplicationDocumentsDirectory();
    final sanitizedNumber = invoiceNumber.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final file = File('${outputDir.path}/DishaMakeover_Invoice_$sanitizedNumber.pdf');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  /// Print or share directly using printing package
  static Future<void> printInvoice({
    required InvoiceModel invoice,
    required BusinessProfileModel business,
  }) async {
    final pdfBytes = await generateInvoicePdf(invoice: invoice, business: business);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'DishaMakeover_${invoice.invoiceNumber}',
    );
  }
}
