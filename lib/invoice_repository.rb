require 'pry'
require_relative "invoice"
require_relative "sales_engine"
require 'csv'

class InvoiceRepository
  attr_reader :sales_engine, :invoices
  def initialize(value_at_invoice, sales_engine)
    @invoices = []
    @sales_engine = sales_engine
    make_invoices(value_at_invoice)
  end

  def inspect
    "#<#{self.class} #{@invoices.size} rows>"
  end

  def make_invoices(invoice_hashes)
    invoice_hashes.each do |invoice_hash|
      @invoices << Invoice.new(invoice_hash, self)
    end
    @invoices
  end

  def find_total(merchant_id)
    items = @sales_engine.merchants.find_items(merchant_id)
    items.reduce(0) { |sum, item| sum += item.unit_price.to_f }
  end

  def find_transactions(invoice_id)
    @sales_engine.transactions.find_all_by_invoice_id(invoice_id)
  end

  def find_merchant(merchant_id)
    @sales_engine.merchants.find_by_id(merchant_id)
  end

  def find_items(invoice_id)
    invoice_items = @sales_engine.invoice_items.find_all_by_invoice_id(invoice_id)
    item_ids = invoice_items.map { |item| item.item_id }
    items = item_ids.map { |id| @sales_engine.items.find_by_id(id)}
    items.compact
  end

  def find_customer(customer_id)
    @sales_engine.customers.find_by_id(customer_id)
  end

  def all
    @invoices
  end

  def find_by_id(invoice_id)
    @invoices.find { |object| object.id == invoice_id }
  end

  def find_all_by_customer_id(id)
    @invoices.find_all { |object| object.customer_id == id }
  end

  def find_all_by_merchant_id(id)
    @invoices.find_all { |object| object.merchant_id == id }
  end

  def find_all_by_status(status)
    @invoices.find_all { |object| object.status == status }
  end
end
