## README
### How to connect to the oracle database
1. Open SQLDeveloper and click connect.
 Enter the following: `Database Name`: `apps_query`
                       `Password`: `apps_query`
                       `host`: `demo.enginatics.com`
                       `port`: `1521`
                       `service name`: `ebs_ebsdb`
### Purpose:
This SQL query retrieves information related to unpaid or partially paid invoices along with their associated details such as vendor information, payment status, invoice amounts, and more. The query is designed to be used within an Oracle database environment.

### SQL Query Description:
The SQL query selects various fields from multiple tables to construct a comprehensive dataset of invoice-related information. It utilizes joins to link tables together based on their relationships, ensuring accurate and complete data retrieval.

### Tables Involved:
- `ap_invoices_all`: Main table containing general invoice information.
- `ap_invoice_lines_all`: Table containing line-level details for invoices.
- `ap_invoice_distributions_all`: Table containing distribution details for invoice lines.
- `ap_suppliers`: Table storing supplier information.
- `ap_supplier_sites_all`: Table storing supplier site information.
- `po_headers_all`: Table storing purchase order header information.
- `gl_code_combinations_kfv`: Table storing code combinations for General Ledger.
- `ap_invoice_payments_all`: Table storing payment information for invoices.
- `ap_checks_all`: Table storing check information.
- `ap_payment_schedules_all`: Table storing payment schedule information.
- `ap_terms`: Table storing payment terms information.
- `hr_operating_units`: Table storing operating unit information.
- `gl_ledgers`: Table storing ledger information.

### Usage:
- This query can be executed within an Oracle SQL environment.
- Replace `:P_ORG_ID`, `:P_start_inv_date`, and `:P_end_inv_date` with actual parameter values before execution.
- It retrieves data based on the specified organization ID and invoice date range.

### Note:
- Ensure that appropriate access privileges are granted to execute the query against the necessary tables.
- Modify the query as needed to suit specific reporting requirements or additional filtering criteria.
- Review and validate the results carefully before using them for any further analysis or reporting purposes.

### Disclaimer:
- This SQL query is provided as-is, without any guarantees or warranties.
- Users are encouraged to review, test, and customize the query according to their specific requirements and database environment.

### SQL Query
```sql
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
   ```