CREATE SCHEMA IF NOT EXISTS lighthouse;

CREATE TABLE IF NOT EXISTS lighthouse.addresses (
    "id" BIGINT PRIMARY KEY,
    "customer_id" BIGINT,
    "address_type" TEXT,
    "postal_code" TEXT,
    "street" TEXT,
    "number" BIGINT,
    "complement" TEXT,
    "district" TEXT,
    "city" TEXT,
    "state" TEXT,
    "country" TEXT,
    "is_primary" TEXT
);

CREATE TABLE IF NOT EXISTS lighthouse.attributes (
    "id" BIGINT PRIMARY KEY,
    "name" TEXT,
    "data_type" TEXT
);

CREATE TABLE IF NOT EXISTS lighthouse.brands (
    "id" BIGINT PRIMARY KEY,
    "name" TEXT,
    "country" TEXT,
    "is_active" TEXT,
    "created_at" TIMESTAMP,
    "updated_at" TIMESTAMP
);

CREATE TABLE IF NOT EXISTS lighthouse.categories (
    "id" BIGINT PRIMARY KEY,
    "name" TEXT,
    "slug" TEXT,
    "parent_category_id" BIGINT,
    "is_active" TEXT,
    "created_at" TIMESTAMP,
    "updated_at" TIMESTAMP
);

CREATE TABLE IF NOT EXISTS lighthouse.customers (
    "id" BIGINT PRIMARY KEY,
    "person_type" TEXT,
    "legal_name" TEXT,
    "trade_name" TEXT,
    "tax_id" BIGINT,
    "state_registration" TEXT,
    "email" TEXT,
    "phone" TEXT,
    "is_active" TEXT,
    "created_at" TIMESTAMP,
    "updated_at" TIMESTAMP
);

CREATE TABLE IF NOT EXISTS lighthouse.employees (
    "id" BIGINT PRIMARY KEY,
    "full_name" TEXT,
    "cpf" BIGINT,
    "email" TEXT,
    "role" TEXT,
    "primary_location_id" BIGINT,
    "hire_date" TIMESTAMP,
    "termination_date" TIMESTAMP,
    "is_active" TEXT,
    "created_at" TIMESTAMP,
    "updated_at" TIMESTAMP
);

CREATE TABLE IF NOT EXISTS lighthouse.fiscal_invoices (
    "id" BIGINT PRIMARY KEY,
    "order_id" BIGINT,
    "nfe_number" TEXT,
    "nfe_access_key" TEXT,
    "series" BIGINT,
    "issued_at" TIMESTAMP,
    "status" TEXT,
    "total_amount" DOUBLE PRECISION,
    "xml_storage_uri" TEXT,
    "created_at" TIMESTAMP,
    "updated_at" TIMESTAMP
);

CREATE TABLE IF NOT EXISTS lighthouse.goods_receipts (
    "id" BIGINT PRIMARY KEY,
    "purchase_order_id" BIGINT,
    "received_by_employee_id" BIGINT,
    "received_at" TIMESTAMP,
    "notes" TEXT,
    "created_at" TIMESTAMP
);

CREATE TABLE IF NOT EXISTS lighthouse.goods_receipt_items (
    "id" BIGINT PRIMARY KEY,
    "goods_receipt_id" BIGINT,
    "purchase_order_item_id" BIGINT,
    "quantity_received" DOUBLE PRECISION
);

CREATE TABLE IF NOT EXISTS lighthouse.locations (
    "id" BIGINT PRIMARY KEY,
    "name" TEXT,
    "location_type" TEXT,
    "postal_code" TEXT,
    "street" TEXT,
    "number" BIGINT,
    "complement" TEXT,
    "district" TEXT,
    "city" TEXT,
    "state" TEXT,
    "country" TEXT,
    "is_active" TEXT,
    "created_at" TIMESTAMP,
    "updated_at" TIMESTAMP
);

CREATE TABLE IF NOT EXISTS lighthouse.orders (
    "id" BIGINT PRIMARY KEY,
    "order_number" TEXT,
    "channel" TEXT,
    "customer_id" BIGINT,
    "salesperson_id" BIGINT,
    "location_id" BIGINT,
    "status" TEXT,
    "subtotal" DOUBLE PRECISION,
    "discount_amount" DOUBLE PRECISION,
    "total" DOUBLE PRECISION,
    "placed_at" TIMESTAMP,
    "created_at" TIMESTAMP,
    "updated_at" TIMESTAMP
);

CREATE TABLE IF NOT EXISTS lighthouse.order_items (
    "id" BIGINT PRIMARY KEY,
    "order_id" BIGINT,
    "product_variant_id" BIGINT,
    "quantity" BIGINT,
    "unit_price" DOUBLE PRECISION,
    "icms_rate" DOUBLE PRECISION,
    "ipi_rate" DOUBLE PRECISION,
    "line_total" DOUBLE PRECISION
);

CREATE TABLE IF NOT EXISTS lighthouse.payments (
    "id" BIGINT PRIMARY KEY,
    "order_id" BIGINT,
    "method" TEXT,
    "installments" BIGINT,
    "amount" DOUBLE PRECISION,
    "status" TEXT,
    "paid_at" TIMESTAMP,
    "created_at" TIMESTAMP,
    "updated_at" TIMESTAMP
);

CREATE TABLE IF NOT EXISTS lighthouse.products (
    "id" BIGINT PRIMARY KEY,
    "name" TEXT,
    "description" TEXT,
    "brand_id" BIGINT,
    "category_id" BIGINT,
    "ncm_code" BIGINT,
    "unit_of_measure" TEXT,
    "is_active" TEXT,
    "created_at" TIMESTAMP,
    "updated_at" TIMESTAMP
);

CREATE TABLE IF NOT EXISTS lighthouse.product_suppliers (
    "product_variant_id" BIGINT,
    "supplier_id" BIGINT,
    "supplier_sku" TEXT,
    "last_quoted_cost" DOUBLE PRECISION,
    "lead_time_days" BIGINT,
    "is_preferred" TEXT,
    "created_at" TIMESTAMP,
    "updated_at" TIMESTAMP
);

CREATE TABLE IF NOT EXISTS lighthouse.product_variants (
    "id" BIGINT PRIMARY KEY,
    "product_id" BIGINT,
    "sku" TEXT,
    "barcode_ean" BIGINT,
    "sale_price" DOUBLE PRECISION,
    "cost_price" DOUBLE PRECISION,
    "weight_kg" DOUBLE PRECISION,
    "icms_rate" DOUBLE PRECISION,
    "ipi_rate" DOUBLE PRECISION,
    "is_active" TEXT,
    "created_at" TIMESTAMP,
    "updated_at" TIMESTAMP
);

CREATE TABLE IF NOT EXISTS lighthouse.purchase_orders (
    "id" BIGINT PRIMARY KEY,
    "po_number" TEXT,
    "supplier_id" BIGINT,
    "buyer_id" BIGINT,
    "destination_location_id" BIGINT,
    "status" TEXT,
    "currency" TEXT,
    "subtotal" DOUBLE PRECISION,
    "total" DOUBLE PRECISION,
    "placed_at" TIMESTAMP,
    "expected_delivery_at" TIMESTAMP,
    "created_at" TIMESTAMP,
    "updated_at" TIMESTAMP
);

CREATE TABLE IF NOT EXISTS lighthouse.purchase_order_items (
    "id" BIGINT PRIMARY KEY,
    "purchase_order_id" BIGINT,
    "product_variant_id" BIGINT,
    "quantity_ordered" BIGINT,
    "unit_cost" DOUBLE PRECISION,
    "line_total" DOUBLE PRECISION
);

CREATE TABLE IF NOT EXISTS lighthouse.returns (
    "id" BIGINT PRIMARY KEY,
    "return_number" TEXT,
    "order_id" BIGINT,
    "customer_id" BIGINT,
    "received_at_location_id" BIGINT,
    "status" TEXT,
    "reason" TEXT,
    "total_refund_amount" DOUBLE PRECISION,
    "created_at" TIMESTAMP,
    "updated_at" TIMESTAMP
);

CREATE TABLE IF NOT EXISTS lighthouse.return_items (
    "id" BIGINT PRIMARY KEY,
    "return_id" BIGINT,
    "order_item_id" BIGINT,
    "quantity" DOUBLE PRECISION,
    "action" TEXT,
    "exchange_variant_id" BIGINT,
    "unit_refund_amount" DOUBLE PRECISION
);

CREATE TABLE IF NOT EXISTS lighthouse.stock_levels (
    "product_variant_id" BIGINT,
    "location_id" BIGINT,
    "quantity_on_hand" DOUBLE PRECISION,
    "reorder_point" BIGINT,
    "updated_at" TIMESTAMP
);

CREATE TABLE IF NOT EXISTS lighthouse.stock_movements (
    "id" BIGINT PRIMARY KEY,
    "product_variant_id" BIGINT,
    "location_id" BIGINT,
    "movement_type" TEXT,
    "quantity" DOUBLE PRECISION,
    "reference_table" TEXT,
    "reference_id" BIGINT,
    "employee_id" BIGINT,
    "notes" TEXT,
    "occurred_at" TIMESTAMP,
    "created_at" TIMESTAMP
);

CREATE TABLE IF NOT EXISTS lighthouse.suppliers (
    "id" BIGINT PRIMARY KEY,
    "legal_name" TEXT,
    "trade_name" TEXT,
    "country" TEXT,
    "tax_id" TEXT,
    "tax_id_type" TEXT,
    "email" TEXT,
    "phone" BIGINT,
    "contact_name" TEXT,
    "is_active" TEXT,
    "created_at" TIMESTAMP,
    "updated_at" TIMESTAMP
);

CREATE TABLE IF NOT EXISTS lighthouse.variant_attribute_values (
    "product_variant_id" BIGINT,
    "attribute_id" BIGINT,
    "value" TEXT
);

