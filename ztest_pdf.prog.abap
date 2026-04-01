REPORT ztest_pdf.

DATA(lo_pdf) = zcl_open_abap_pdf=>create( ).
lo_pdf->add_page( ).
lo_pdf->set_font( iv_name = 'Helvetica' iv_size = 24 ).
lo_pdf->text( iv_x = 50 iv_y = 100 iv_text = 'Hello SAP!' ).
DATA(lv_pdf) = lo_pdf->render_binary( ).

" Binary conversion
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

" Save dialog
DATA lv_filename TYPE string.
DATA lv_path     TYPE string.
DATA lv_fullpath TYPE string.
DATA lv_action   TYPE i.

cl_gui_frontend_services=>file_save_dialog(
  EXPORTING
    window_title      = 'Save PDF'
    default_extension = 'pdf'
    default_file_name = 'test.pdf'
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
  WRITE 'PDF generated successfully!'.
ENDIF.
