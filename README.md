# 🌸 Disha Makeover - Beauty Parlour Billing & Invoice App

> *"Beauty Brings Out the Best in You"*

A luxury, glassmorphic billing, invoice management, product catalog, and WhatsApp receipt generation application custom-built for **Disha Makeover**, owned by **Prof. Tejal Patel** (+91 9428195591).

---

## 💎 Features & Highlights

### 1. 🪟 Luxury Glass Window UI (Glassmorphism)
- Designed around the official **Disha Makeover** brand identity:
  - **Royal Burgundy / Deep Wine** (`#800C36` & `#4A081E`)
  - **Metallic Champagne Gold** (`#D4AF37` & `#F3E5AB`)
  - **Frosted Glass Cards & Luminous Ambient Backdrops** with real `BackdropFilter` gaussian blur and gold rim lighting.
- The official Disha Makeover circular and banner logos are integrated into the app bar, headers, profile, and PDF generator.

### 2. 🧾 Smart Makeover Billing & Invoicing
- **Sequential Invoices**: Automatically generates standardized invoice codes (`DM-2026-0001`, `DM-2026-0002`...).
- **Auto-Save Product Feature**: Whenever an invoice is generated with a new product, it is **automatically saved into your catalog** so the owner never has to type it again!
- **Autocomplete Search**: While billing, simply start typing to find any saved treatment or cosmetic item with instant price and category auto-fill.
- **Returning Customer Auto-Detect**: Enter customer phone or name to instantly auto-fill past details and track customer loyalty.
- **Discounts & GST**: One-tap preset discount chips (₹50, ₹100, ₹200, ₹500) and optional GST/tax tiers (0%, 5%, 12%, 18%).
- **Payment Modes**: Supports UPI / GPay / PhonePe / Paytm, Cash, Card, and Due / Credit tracking.

### 3. 📄 High-Definition PDF Invoice Generator
- Generates pixel-perfect, print-ready A4 PDF invoices using `pdf` and `printing`.
- Features Disha Makeover circular logo, business details, customer bill-to box, itemized breakdown, tax/discount calculation, UPI payment details, and authorized signature for **Prof. Tejal Patel**.
- Instant in-app PDF preview, direct thermal/Wi-Fi printing, and device file saving.

### 4. 💬 Professional WhatsApp Sharing
- Sends formatted receipts directly to the customer's phone via WhatsApp (`wa.me` & native app):
  - Brand header & tagline: *Disha Makeover - Beauty Brings Out the Best in You*
  - Invoice number, date, and payment status
  - Itemized purchase breakdown with quantities and prices
  - Subtotal, discounts, GST, and grand total
  - Owner contact info (Prof. Tejal Patel, +91 9428195591)
- Share the **PDF file directly to WhatsApp** with the accompanying receipt text in a single tap!

### 5. 📦 Product & Service Catalog
- Full catalog management for:
  - Skin Care (O3+ Facial Kits, D-Tan, Serums)
  - Hair Care (L'Oreal Hair Spa, Keratin, Serums)
  - Makeup & Cosmetics (Kryolan TV Paint Stick, Mac Studio Fix, Huda Beauty)
  - Salon Treatments (Bridal Packages, Hydra Glow Facials)
- Stock quantity alerts, cost price, selling price, and usage counts.

### 6. 👥 Customer Directory & CRM
- Tracks lifetime spending, number of visits, last visit dates, and customer preferences.
- One-tap "Call (+91)" and "Message on WhatsApp" shortcuts.

### 7. 📊 Executive Dashboard & Analytics
- Today's Sales, Month's Sales, Total Invoices Generated, and Balance Due.
- Interactive weekly sales trend chart using `fl_chart`.
- Top-selling products and recent invoices with instant action buttons.

### 8. ☁️ Live Firebase Cloud Database Sync
- Built with zero authentication needed (designed for the parlour owner).
- Works **100% offline-first** using persistent local storage, and seamlessly live-syncs to **Firebase Cloud Firestore** via REST API.
- Owner can enter their Firebase Project ID in Settings and click **"Sync to Cloud"** to backup or push live.

---

## 🚀 How to Run the App

### Prerequisites
- Flutter SDK 3.x installed
- Windows Desktop / Android device / Chrome

### Run on Windows Desktop:
```bash
cd "C:\Users\USER\.gemini\antigravity\scratch\disha_makeover"
flutter run -d windows
```

### Run on Chrome (Web):
```bash
cd "C:\Users\USER\.gemini\antigravity\scratch\disha_makeover"
flutter run -d chrome
```

### Run on Connected Android Phone:
```bash
cd "C:\Users\USER\.gemini\antigravity\scratch\disha_makeover"
flutter run -d android
```

### Build Android APK:
```bash
cd "C:\Users\USER\.gemini\antigravity\scratch\disha_makeover"
flutter build apk --release
```

---

## 📁 Project Architecture

```
lib/
├── main.dart                                # App entry point & theme initialization
├── core/
│   ├── theme/
│   │   ├── app_colors.dart                  # Official Disha Makeover Wine & Gold Palette
│   │   └── app_theme.dart                   # Luxury Dark Theme with Google Fonts
│   ├── widgets/
│   │   ├── glass_scaffold.dart              # Multi-stop luxury ambient gradient scaffold
│   │   ├── glass_card.dart                  # Frosted glass card with BackdropFilter blur
│   │   ├── glass_button.dart                # Gold & wine gradient glossy buttons
│   │   ├── glass_text_field.dart            # Frosted glass inputs with gold focus rings
│   │   └── stat_card.dart                   # Dashboard metric card
│   └── utils/
│       ├── currency_format.dart             # Indian Rupee format (₹)
│       ├── date_format.dart                 # Date & invoice code formatting
│       └── whatsapp_helper.dart             # WhatsApp URL launching & PDF sharing
├── models/
│   ├── product_model.dart                   # Beauty product / treatment model
│   ├── customer_model.dart                  # Customer directory & history model
│   ├── invoice_item_model.dart              # Line item model
│   ├── invoice_model.dart                   # Complete invoice model
│   └── business_profile_model.dart          # Parlour owner details model
├── services/
│   ├── storage_service.dart                 # Persistent SharedPreferences & local caching
│   ├── pdf_invoice_service.dart             # PDF generator with printing & logo embedding
│   ├── firebase_service.dart                # Firebase Cloud Firestore REST live sync
│   └── sample_data_service.dart             # Preloaded realistic beauty products & clients
├── state/
│   └── app_state.dart                       # Central Reactive State Manager
└── screens/
    ├── main_navigation_screen.dart          # Glassmorphic bottom navigation
    ├── dashboard/
    │   └── dashboard_screen.dart            # Analytics, weekly sales chart, recent bills
    ├── invoice/
    │   ├── create_invoice_screen.dart       # Smart billing screen with auto-save & auto-suggest
    │   ├── invoice_list_screen.dart         # Invoice search, filters, and records
    │   └── pdf_preview_screen.dart          # Fullscreen PDF viewer & WhatsApp sharing
    ├── catalog/
    │   ├── product_catalog_screen.dart      # Catalog browser & stock tracker
    │   └── add_edit_product_dialog.dart     # Product create / edit modal
    ├── customers/
    │   └── customers_screen.dart            # Customer directory with call & WhatsApp
    └── settings/
        └── business_profile_screen.dart     # Owner profile & Firebase sync settings
```

---

© **Disha Makeover** • Prof. Tejal Patel • +91 9428195591
