import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/invoice_model.dart';
import '../../models/business_profile_model.dart';
import 'currency_format.dart';
import 'date_format.dart';

class WhatsAppHelper {
  /// Cleans and formats phone number for WhatsApp wa.me API
  static String cleanPhoneNumber(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length == 10) {
      cleaned = '91$cleaned';
    } else if (cleaned.startsWith('0') && cleaned.length == 11) {
      cleaned = '91${cleaned.substring(1)}';
    }
    return cleaned;
  }

  /// Generates a professional WhatsApp receipt message
  static String buildInvoiceMessage(
    InvoiceModel invoice,
    BusinessProfileModel business,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('🌸 *${business.businessName.toUpperCase()}* 🌸');
    buffer.writeln('_${business.tagline}_');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('Hello *${invoice.customer.name}*,');
    buffer.writeln('Thank you for choosing *${business.businessName}*! Here is your bill summary:');
    buffer.writeln('');
    buffer.writeln('🧾 *Invoice No:* #${invoice.invoiceNumber}');
    buffer.writeln('📅 *Date:* ${DateHelper.format(invoice.date)}');
    buffer.writeln('💳 *Payment:* ${invoice.paymentStatus.toUpperCase()} (${invoice.paymentMode})');
    buffer.writeln('');
    buffer.writeln('🛍️ *Items Purchased:*');

    for (var i = 0; i < invoice.items.length; i++) {
      final item = invoice.items[i];
      buffer.writeln(
        '  ${i + 1}. *${item.name}* (x${item.quantity}) - ${CurrencyHelper.format(item.total)}',
      );
    }

    buffer.writeln('────────────────────');
    buffer.writeln('💵 *Subtotal:* ${CurrencyHelper.format(invoice.subtotal)}');
    if (invoice.discountAmount > 0) {
      buffer.writeln('🎁 *Discount:* -${CurrencyHelper.format(invoice.discountAmount)}');
    }
    if (invoice.taxAmount > 0) {
      buffer.writeln('🏛️ *GST/Tax (${invoice.taxPercentage.toInt()}%):* +${CurrencyHelper.format(invoice.taxAmount)}');
    }
    buffer.writeln('💰 *Total Amount:* *${CurrencyHelper.format(invoice.grandTotal)}*');

    if (invoice.paymentStatus.toLowerCase() == 'partial' ||
        invoice.paymentStatus.toLowerCase() == 'unpaid') {
      final balance = invoice.grandTotal - invoice.amountPaid;
      buffer.writeln('⚠️ *Balance Due:* ${CurrencyHelper.format(balance)}');
    }

    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('📞 For bookings & beauty tips:');
    buffer.writeln('${business.ownerName} (${business.phone})');
    if (business.address.isNotEmpty) {
      buffer.writeln('📍 ${business.address}');
    }
    buffer.writeln('');
    buffer.writeln('✨ _Beauty Brings Out the Best in You!_ ✨');

    return buffer.toString();
  }

  /// Opens WhatsApp with the invoice text directly to the customer's phone
  static Future<bool> sendWhatsAppMessage({
    required InvoiceModel invoice,
    required BusinessProfileModel business,
  }) async {
    final cleanedPhone = cleanPhoneNumber(invoice.customer.phone);
    final message = buildInvoiceMessage(invoice, business);
    final encodedMessage = Uri.encodeComponent(message);

    // Try wa.me deep link
    final waUri = Uri.parse('https://wa.me/$cleanedPhone?text=$encodedMessage');
    final nativeWaUri = Uri.parse('whatsapp://send?phone=$cleanedPhone&text=$encodedMessage');

    try {
      if (await canLaunchUrl(nativeWaUri)) {
        return await launchUrl(nativeWaUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(waUri)) {
        return await launchUrl(waUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(waUri, mode: LaunchMode.platformDefault);
        return true;
      }
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
      return false;
    }
  }

  /// Shares PDF file and accompanying WhatsApp text via Share Sheet
  static Future<void> sharePdfWithWhatsAppText({
    required String pdfFilePath,
    required InvoiceModel invoice,
    required BusinessProfileModel business,
  }) async {
    final message = buildInvoiceMessage(invoice, business);
    final xFile = XFile(pdfFilePath, mimeType: 'application/pdf');

    await Share.shareXFiles(
      [xFile],
      text: message,
      subject: '${business.businessName} Invoice #${invoice.invoiceNumber}',
    );
  }
}
