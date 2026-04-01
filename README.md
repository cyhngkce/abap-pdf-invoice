# abap-pdf-invoice

A demo ABAP program that generates a sales invoice PDF using [open-abap-pdf](https://github.com/open-abap/open-abap-pdf) — without SmartForms, Adobe Forms, or any external service.

> 📄 Full walkthrough: [Generating PDF in SAP Without SmartForms or Adobe Forms](https://medium.com/@cyhngkce/generating-pdf-in-sap-without-smartforms-or-adobe-forms-abapgit-open-abap-pdf-9bc108d645c8)

---

## About open-abap-pdf

[open-abap-pdf](https://github.com/open-abap/open-abap-pdf) is an open-source library by [Lars Hvam Petersen](https://github.com/larshp) — the creator of abapGit. It generates PDF files entirely within ABAP using a coordinate-based API. No ADS server, no Java sidecar, no external dependencies.

**Limitations:** No automatic page break or text wrap. Best suited for fixed-layout documents like invoices, certificates, or summary reports.

---

## Prerequisites

- SAP system with ABAP (Developer Edition or equivalent)
- [abapGit](https://abapgit.org) installed on your system

---

## Installation

### 1. Install abapGit

If you don't have abapGit yet:

1. Open `SE38` and create a new program named `ZABAPGIT_STANDALONE`
2. Download the standalone version:
   ```
   https://raw.githubusercontent.com/abapGit/build/main/zabapgit_standalone.prog.abap
   ```
3. Upload via **Utilities → More Utilities → Upload/Download → Upload**
4. Save, activate (`Ctrl+F3`), and run (`F8`)

### 2. Install open-abap-pdf (Offline)

> SAP Developer Edition blocks SSL connections to GitHub, so use the offline method.

1. In the abapGit interface, click **"New Offline"**
2. Set **Name:** `ABAP2PDF`, **Package:** `$ZPDF`, **Software Component:** `LOCAL` → Create
3. Download the ZIP:
   ```
   https://github.com/open-abap/open-abap-pdf/archive/refs/heads/main.zip
   ```
4. Click **"Import zip"** and select the downloaded file
5. Click **"Pull zip"**, then activate all objects

### 3. Run the demo

1. Open `SE38` and create a new program named `ZINVOICE_PDF`
2. Copy the contents of [`zinvoice_pdf.prog.abap`](./zinvoice_pdf.prog.abap) into the editor
3. Save, activate, and run (`F8`)
4. A save dialog will open — save the file to your desktop and open it

---

## Code Structure

| Section | Description |
|---|---|
| `ty_invoice_header` | Type definition for invoice header data (company, customer, dates) |
| `ty_invoice_item` | Type definition for line items (document no, amount, VAT rate) |
| Mock data | Static test data — replace with your own table reads in a real scenario |
| Calculations | Subtotal, VAT (20%), and total amount computation |
| PDF generation | Coordinate-based layout using `ZCL_OPEN_ABAP_PDF` methods |
| Binary conversion | Converts `xstring` output to `x255` table for `gui_download` |
| File save dialog | `cl_gui_frontend_services` — requires interactive SAP GUI execution |

### Key API calls used

```abap
lo_pdf->add_page( ).
lo_pdf->set_font( iv_name = 'Helvetica' iv_size = 12 ).
lo_pdf->set_text_color( iv_r = 0 iv_g = 0 iv_b = 0 ).
lo_pdf->text( iv_x = 50 iv_y = 100 iv_text = 'Hello' ).
lo_pdf->line( iv_x1 = 40 iv_y1 = 150 iv_x2 = 555 iv_y2 = 150 ).
DATA(lv_pdf) = lo_pdf->render_binary( ).
```

> **Note:** This demo uses `cl_gui_frontend_services` for file download, which requires interactive execution via SAP GUI. For BTP Cloud ABAP (Steampunk), the binary output should be returned via an OData service instead.

---

## References

- [open-abap-pdf](https://github.com/open-abap/open-abap-pdf) by Lars Hvam Petersen
- [abapGit](https://abapgit.org)
- [Medium article (EN)](https://medium.com/@cyhngkce/generating-pdf-in-sap-without-smartforms-or-adobe-forms-abapgit-open-abap-pdf-9bc108d645c8)
- [Medium article (TR)](https://medium.com/@cyhngkce/sapta-smartforms-ve-adobe-forms-olmadan-pdf-%C3%BCretmek-abapgit-open-abap-pdf-36794ae3b87b)
