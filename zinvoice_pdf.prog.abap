REPORT zinvoice_pdf.

TYPES:
  BEGIN OF ty_invoice_header,
    invoice_no   TYPE string,
    date         TYPE string,
    due_date     TYPE string,
    page         TYPE string,
    company_name TYPE string,
    address1     TYPE string,
    address2     TYPE string,
    phone        TYPE string,
    fax          TYPE string,
    email        TYPE string,
    customer     TYPE string,
    cust_name    TYPE string,
    cust_addr1   TYPE string,
    cust_addr2   TYPE string,
    tax_no       TYPE string,
    iban         TYPE string,
  END OF ty_invoice_header,

  BEGIN OF ty_invoice_item,
    doc_no    TYPE string,
    doc_date  TYPE string,
    currency  TYPE string,
    amount    TYPE p DECIMALS 2, 
    vat_rate  TYPE string,
  END OF ty_invoice_item,

  ty_invoice_items TYPE STANDARD TABLE OF ty_invoice_item WITH DEFAULT KEY.

" Mock data
DATA ls_header TYPE ty_invoice_header.
DATA lt_items  TYPE ty_invoice_items.
DATA ls_item   TYPE ty_invoice_item.

ls_header-invoice_no   = 'INV-2026-00123'.
ls_header-date         = '29.03.2026'.
ls_header-due_date     = '28.04.2026'.
ls_header-page         = '1 / 1'.
ls_header-company_name = 'Demo Company Ltd.'.
ls_header-address1     = 'Sample Street No:125, 34730'.
ls_header-address2     = 'Kadikoy / Istanbul'.
ls_header-phone        = '+90 (216) 000 00 00'.
ls_header-fax          = '+90 (216) 000 00 01'.
ls_header-email        = 'info@democompany.com'.
ls_header-customer     = 'Customer'.
ls_header-cust_name    = 'ABC Trading Co.'.
ls_header-cust_addr1   = 'Ataturk Avenue No:42'.
ls_header-cust_addr2   = '34000 Sisli / Istanbul'.
ls_header-tax_no       = '1234567890'.
ls_header-iban         = 'TR12 0001 0002 0003 0004 0005 06'.

ls_item = VALUE #( doc_no = '1000000001' doc_date = '01.03.2026'
                   currency = 'USD' amount = '3000.00' vat_rate = '20.00 %' ).
APPEND ls_item TO lt_items.
ls_item = VALUE #( doc_no = '1000000002' doc_date = '05.03.2026'
                   currency = 'USD' amount = '250.00' vat_rate = '20.00 %' ).
APPEND ls_item TO lt_items.
ls_item = VALUE #( doc_no = '1000000003' doc_date = '10.03.2026'
                   currency = 'USD' amount = '360.00' vat_rate = '20.00 %' ).
APPEND ls_item TO lt_items.

" Calculations
DATA lv_subtotal TYPE p DECIMALS 2.
DATA lv_vat      TYPE p DECIMALS 2.
DATA lv_total    TYPE p DECIMALS 2.

LOOP AT lt_items INTO ls_item.
  lv_subtotal = lv_subtotal + ls_item-amount.
ENDLOOP.
lv_vat   = lv_subtotal * '0.20'.
lv_total = lv_subtotal + lv_vat.

" Generate PDF
DATA(lo_pdf) = zcl_open_abap_pdf=>create( ).
lo_pdf->add_page( ).

CONSTANTS: c_left  TYPE f VALUE '40',
           c_right TYPE f VALUE '555'.
DATA lv_y TYPE f.

"Company name and hyphen
lo_pdf->set_font( iv_name = 'Helvetica' iv_size = 11 ).
lo_pdf->set_text_color( iv_r = 0 iv_g = 0 iv_b = 0 ).
lo_pdf->text( iv_x = c_left iv_y = '40'
  iv_text = |{ ls_header-company_name } - { ls_header-address1 }, { ls_header-address2 }| ).

lo_pdf->set_draw_color( iv_r = 0 iv_g = 0 iv_b = 0 ).
lo_pdf->set_line_width( iv_width = '0.5' ).
lo_pdf->line( iv_x1 = c_left iv_y1 = '50' iv_x2 = c_right iv_y2 = '50' ).

"INVOICE heading 
lo_pdf->set_font( iv_name = 'Helvetica' iv_size = 18 ).
lo_pdf->text( iv_x = '260' iv_y = '72' iv_text = 'INVOICE' ).

“Customer address (left)
lo_pdf->set_font( iv_name = 'Helvetica' iv_size = 9 ).
lo_pdf->set_text_color( iv_r = 100 iv_g = 100 iv_b = 100 ).
lo_pdf->text( iv_x = c_left iv_y = '90' iv_text = ls_header-customer ).
lo_pdf->set_text_color( iv_r = 0 iv_g = 0 iv_b = 0 ).
lo_pdf->text( iv_x = c_left iv_y = '102' iv_text = ls_header-cust_name ).
lo_pdf->text( iv_x = c_left iv_y = '114' iv_text = ls_header-cust_addr1 ).
lo_pdf->text( iv_x = c_left iv_y = '126' iv_text = ls_header-cust_addr2 ).

"Invoice details (right)
lo_pdf->set_text_color( iv_r = 80 iv_g = 80 iv_b = 80 ).
lo_pdf->text( iv_x = '320' iv_y = '90'  iv_text = 'Date' ).
lo_pdf->text( iv_x = '320' iv_y = '102' iv_text = 'Page' ).
lo_pdf->text( iv_x = '320' iv_y = '118' iv_text = 'Account No' ).
lo_pdf->text( iv_x = '320' iv_y = '130' iv_text = 'Contact' ).
lo_pdf->text( iv_x = '320' iv_y = '142' iv_text = 'Phone' ).
lo_pdf->text( iv_x = '320' iv_y = '154' iv_text = 'Fax' ).
lo_pdf->text( iv_x = '320' iv_y = '166' iv_text = 'Email' ).

lo_pdf->set_text_color( iv_r = 0 iv_g = 0 iv_b = 0 ).
lo_pdf->text( iv_x = '420' iv_y = '90'  iv_text = ls_header-date ).
lo_pdf->text( iv_x = '420' iv_y = '102' iv_text = ls_header-page ).
lo_pdf->text( iv_x = '420' iv_y = '118' iv_text = ls_header-tax_no ).
lo_pdf->text( iv_x = '420' iv_y = '130' iv_text = 'John Doe' ).
lo_pdf->text( iv_x = '420' iv_y = '142' iv_text = ls_header-phone ).
lo_pdf->text( iv_x = '420' iv_y = '154' iv_text = ls_header-fax ).
lo_pdf->text( iv_x = '420' iv_y = '166' iv_text = ls_header-email ).

"Separator line
lo_pdf->set_draw_color( iv_r = 180 iv_g = 180 iv_b = 180 ).
lo_pdf->set_line_width( iv_width = '0.5' ).
lo_pdf->line( iv_x1 = c_left iv_y1 = '180' iv_x2 = c_right iv_y2 = '180' ).

" Invoice PDF header (greeting, description, IBAN information)
" No automatic line breaks in the library—each line requires a separate text() call
lo_pdf->set_font( iv_name = 'Helvetica' iv_size = 9 ).
lo_pdf->set_text_color( iv_r = 0 iv_g = 0 iv_b = 0 ).
lo_pdf->text( iv_x = c_left iv_y = '196' iv_text = 'Dear Sir/Madam,' ).
lo_pdf->text( iv_x = c_left iv_y = '210'
  iv_text = 'Please find below the details of our invoice for your records.' ).
lo_pdf->text( iv_x = c_left iv_y = '224'
  iv_text = |Payment IBAN: { ls_header-iban }| ).
lo_pdf->text( iv_x = c_left iv_y = '238' iv_text = 'Kind regards,' ).
lo_pdf->text( iv_x = c_left iv_y = '252' iv_text = ls_header-company_name ).

"Separator line
lo_pdf->set_draw_color( iv_r = 180 iv_g = 180 iv_b = 180 ).
lo_pdf->line( iv_x1 = c_left iv_y1 = '262' iv_x2 = c_right iv_y2 = '262' ).

"Table heading
lo_pdf->set_font( iv_name = 'Helvetica' iv_size = 9 ).
lo_pdf->set_text_color( iv_r = 80 iv_g = 80 iv_b = 80 ).
lo_pdf->text( iv_x = c_left iv_y = '278' iv_text = 'Document No.' ).
lo_pdf->text( iv_x = '180'  iv_y = '278' iv_text = 'Document Date' ).
lo_pdf->text( iv_x = '300'  iv_y = '278' iv_text = 'Currency' ).
lo_pdf->text( iv_x = '400'  iv_y = '278' iv_text = 'Amount' ).
lo_pdf->text( iv_x = '490'  iv_y = '278' iv_text = 'VAT Rate' ).

lo_pdf->set_draw_color( iv_r = 180 iv_g = 180 iv_b = 180 ).
lo_pdf->line( iv_x1 = c_left iv_y1 = '283' iv_x2 = c_right iv_y2 = '283' ).

" Table rows - lv_y is dynamic, shifting down 16pt in each row
lv_y = '296'.
DATA lv_amount_str TYPE string.

LOOP AT lt_items INTO ls_item.
  lv_amount_str = ls_item-amount.
  CONDENSE lv_amount_str.
  CONCATENATE lv_amount_str ' USD' INTO lv_amount_str.

  lo_pdf->set_text_color( iv_r = 0 iv_g = 0 iv_b = 0 ).
  lo_pdf->set_font( iv_name = 'Helvetica' iv_size = 9 ).
  lo_pdf->text( iv_x = c_left iv_y = lv_y iv_text = ls_item-doc_no ).
  lo_pdf->text( iv_x = '180'  iv_y = lv_y iv_text = ls_item-doc_date ).
  lo_pdf->text( iv_x = '300'  iv_y = lv_y iv_text = ls_item-currency ).
  lo_pdf->text( iv_x = '400'  iv_y = lv_y iv_text = lv_amount_str ).
  lo_pdf->text( iv_x = '490'  iv_y = lv_y iv_text = ls_item-vat_rate ).

  lo_pdf->set_draw_color( iv_r = 220 iv_g = 220 iv_b = 220 ).
  lo_pdf->set_line_width( iv_width = '0.3' ).
  lo_pdf->line( iv_x1 = c_left iv_y1 = lv_y + '4'
                iv_x2 = c_right iv_y2 = lv_y + '4' ).

  lv_y = lv_y + '16'.
ENDLOOP.

"Value Added Tax line
DATA lv_vat_str      TYPE string.
DATA lv_subtotal_str TYPE string.
lv_subtotal_str = lv_subtotal. CONDENSE lv_subtotal_str.
lv_vat_str      = lv_vat.      CONDENSE lv_vat_str.
CONCATENATE lv_subtotal_str ' USD' INTO lv_subtotal_str.
CONCATENATE lv_vat_str      ' USD' INTO lv_vat_str.

lo_pdf->set_text_color( iv_r = 0 iv_g = 0 iv_b = 0 ).
lo_pdf->set_font( iv_name = 'Helvetica' iv_size = 9 ).
lo_pdf->text( iv_x = c_left iv_y = lv_y iv_text = 'Value Added Tax' ).
lo_pdf->text( iv_x = '300'  iv_y = lv_y iv_text = '20.00 %' ).
lo_pdf->text( iv_x = '360'  iv_y = lv_y iv_text = 'USD' ).
lo_pdf->text( iv_x = '400'  iv_y = lv_y iv_text = lv_vat_str ).

lo_pdf->set_draw_color( iv_r = 220 iv_g = 220 iv_b = 220 ).
lo_pdf->set_line_width( iv_width = '0.3' ).
lo_pdf->line( iv_x1 = c_left iv_y1 = lv_y + '4'
              iv_x2 = c_right iv_y2 = lv_y + '4' ).
lv_y = lv_y + '16'.

"Total
DATA lv_total_str TYPE string.
lv_total_str = lv_total. CONDENSE lv_total_str.
CONCATENATE lv_total_str ' USD' INTO lv_total_str.

lo_pdf->set_draw_color( iv_r = 0 iv_g = 0 iv_b = 0 ).
lo_pdf->set_line_width( iv_width = '0.5' ).
lo_pdf->line( iv_x1 = c_left iv_y1 = lv_y - '4'
              iv_x2 = c_right iv_y2 = lv_y - '4' ).

lo_pdf->set_font( iv_name = 'Helvetica' iv_size = 10 ).
lo_pdf->set_text_color( iv_r = 0 iv_g = 0 iv_b = 0 ).
lo_pdf->text( iv_x = c_left iv_y = lv_y + '6' iv_text = 'Total Amount' ).
lo_pdf->text( iv_x = '300'  iv_y = lv_y + '6' iv_text = 'USD' ).
lo_pdf->text( iv_x = '400'  iv_y = lv_y + '6' iv_text = lv_total_str ).

lo_pdf->set_draw_color( iv_r = 0 iv_g = 0 iv_b = 0 ).
lo_pdf->line( iv_x1 = c_left iv_y1 = lv_y + '16'
              iv_x2 = c_right iv_y2 = lv_y + '16' ).

" Footer
DATA lv_footer_y TYPE f.
lv_footer_y = lv_y + '60'.

lo_pdf->set_draw_color( iv_r = 180 iv_g = 180 iv_b = 180 ).
lo_pdf->set_line_width( iv_width = '0.5' ).
lo_pdf->line( iv_x1 = c_left  iv_y1 = lv_footer_y
              iv_x2 = c_right iv_y2 = lv_footer_y ).
lv_footer_y = lv_footer_y + '12'.
lo_pdf->set_font( iv_name = 'Helvetica' iv_size = 8 ).
lo_pdf->set_text_color( iv_r = 150 iv_g = 150 iv_b = 150 ).
lo_pdf->text( iv_x = c_left iv_y = lv_footer_y
  iv_text = |{ ls_header-company_name } | &&
            |{ ls_header-address1 }, { ls_header-address2 }| ).
lo_pdf->text( iv_x = '490' iv_y = lv_footer_y iv_text = ls_header-page ).

" Binary conversion - `render_binary()` returns an `xstring`, `gui_download` expects an `x255` table
DATA(lv_pdf) = lo_pdf->render_binary( ).

DATA lt_bin    TYPE STANDARD TABLE OF x255.
DATA lv_line   TYPE x255.
DATA lv_offset TYPE i VALUE 0.
DATA lv_len    TYPE i.
DATA lv_chunk  TYPE i.
lv_len = xstrlen( lv_pdf ).

WHILE lv_offset < lv_len.
  lv_chunk = lv_len - lv_offset.
  IF lv_chunk > 255. lv_chunk = 255. ENDIF.
  lv_line = lv_pdf+lv_offset(lv_chunk).
  APPEND lv_line TO lt_bin.
  lv_offset = lv_offset + lv_chunk.
ENDWHILE.

" A save dialog box opens, allowing the user to select a file path and name
DATA lv_filename TYPE string.
DATA lv_path     TYPE string.
DATA lv_fullpath TYPE string.
DATA lv_action   TYPE i.

cl_gui_frontend_services=>file_save_dialog(
  EXPORTING
    window_title      = 'Save Invoice PDF'
    default_extension = 'pdf'
    default_file_name = 'invoice.pdf'
    file_filter       = 'PDF Files (*.pdf)|*.pdf|'
  CHANGING
    filename          = lv_filename
    path              = lv_path
    fullpath          = lv_fullpath
    user_action       = lv_action ).

IF lv_action = cl_gui_frontend_services=>action_ok.
  cl_gui_frontend_services=>gui_download(
    EXPORTING
      bin_filesize = lv_len
      filename     = lv_fullpath
      filetype     = 'BIN'
    CHANGING
      data_tab     = lt_bin
    EXCEPTIONS
      OTHERS       = 1 ).
  IF sy-subrc = 0.
    WRITE: 'PDF generated:', lv_fullpath.
  ENDIF.
ENDIF.
