select aia.invoice_num,     
       aia.ORG_ID,
       aia.invoice_currency_code,
       aipa.invoice_id,
       DECODE(aia.PAYMENT_STATUS_FLAG,'N','UN-PAID','P','Partial Paid','Y','PAID') PAYMENT_STATUS_FLAG ,
       aia.invoice_date,
       aps.vendor_name,
       apss.vendor_site_code,
       aila.line_number,
       aia.invoice_amount,
       aila.amount line_amount,
       pha.segment1 po_number,
       aila.line_type_lookup_code,
       apt.name Term_name,     
       gcc.concatenated_segments distributed_code_combinations,
       aca.check_number,
       aipa.amount payment_amount,
       apsa.amount_remaining,
       aipa.invoice_payment_type,
       hou.name operating_unit,
       gl.name ledger_name  
  from apps.ap_invoices_all         aia,
       ap_invoice_lines_all         aila,
       ap_invoice_distributions_all aida,
       ap_suppliers aps,
       ap_supplier_sites_all apss,
       po_headers_all pha,
       gl_code_combinations_kfv gcc,
       ap_invoice_payments_all aipa,
       ap_checks_all aca,
       ap_payment_schedules_all apsa,
       ap_terms apt,
       hr_operating_units hou,
       gl_ledgers gl
 where aia.invoice_id = aila.invoice_id
   and aila.invoice_id = aida.invoice_id
   and aila.line_number = aida.invoice_line_number
   and aia.vendor_id=aps.vendor_id
   and aia.PAYMENT_STATUS_FLAG <> 'Y'
   and aia.VENDOR_SITE_ID=APSS.VENDOR_SITE_ID
   AND aps.vendor_id=apss.VENDOR_ID
   and aia.po_header_id=pha.po_header_id(+)
   and aida.dist_code_combination_id=gcc.code_combination_id
   and aipa.invoice_id(+)=aia.invoice_id
   and aca.check_id   (+)=aipa.check_id
   and apsa.invoice_id=aia.invoice_id
   and apt.term_id=aia.terms_id
   and hou.organization_id=aia.org_id
   and gl.ledger_id=aia.set_of_books_id
   and aia.ORG_ID=nvl(:P_ORG_ID,aia.ORG_ID)
   and aia.invoice_date between :P_start_inv_date and :P_end_inv_date
   ;