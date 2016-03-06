 require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/invoice'
require_relative '../lib/sales_engine'

class InvoiceTest < Minitest::Test

  def setup
    se = SalesEngine.from_csv({
            :merchants     => './fixtures/merchants_fixtures.csv',
            :items         => './fixtures/items_fixtures.csv',
            :invoices      => './fixtures/invoices_fixtures.csv',
            :invoice_items => './fixtures/invoice_items_fixtures.csv',
            :transactions  => './fixtures/transactions_fixtures.csv',
            :customers => './fixtures/customers_fixtures.csv'
            })
    ir = se.invoices
    @invoice = ir.find_by_id(1)
    @unpaid_invoice = ir.find_by_id(6)

    # @invoice = Invoice.new({
    #   id: 1,
    #   costumer_id: 1,
    #   merchant_id: 14784142,
    #   status: :pending,
    #   created_at: '2009-02-07',
    #   updated_at: '2014-03-15'
    #   },
    #   invoice_repository = nil)
  end

  def test_initalize_organizes_row_value_id
    assert_equal 1, @invoice.id
  end

  def test_initalize_organizes_row_value_merchant_id
    assert_equal 14784142, @invoice.merchant_id
  end

  def test_initalize_organizes_row_value_status
    assert_equal :pending, @invoice.status
  end

  def test_initalize_organizes_row_value_created_at
    assert_equal Time.parse("2009-02-07"), @invoice.created_at
  end

  def test_initalize_organizes_row_value_updated_at
    assert_equal Time.parse("2014-03-15"), @invoice.updated_at
  end

  def test_merchant_finds_invoices_merchant
    assert_equal "NatureDots", @invoice.merchant.name
  end

  def test_items_finds_invoices_items
  assert_equal 263396279, @invoice.items[0].id
  assert_equal 263396255, @invoice.items[1].id
  assert_equal 263396255, @invoice.items[2].id
  assert_equal nil, @invoice.items[3]
  assert_equal 3, @invoice.items.count
  end

  def test_transactions_finds_invoices_transactions
    assert_equal 13, @invoice.transactions[0].id
    assert_equal nil, @invoice.transactions[1]
    assert_equal 1, @invoice.transactions.count
  end

  def test_customer_finds_invoices_customer
    assert_equal "Joey", @invoice.customer.first_name
  end

  def test_is_paid_in_full_returns_boolean
    refute @unpaid_invoice.is_paid_in_full?
    assert @invoice.is_paid_in_full?
  end

  def test_total_returns_total_price_of_invoice
    assert_equal 12.0, @invoice.total
  end

end
