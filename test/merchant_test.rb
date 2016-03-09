require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/merchant'
require_relative '../lib/merchant_repository'
require_relative '../lib/item'
require_relative '../lib/item_repository'
require_relative '../lib/sales_engine'

class MerchantTest < Minitest::Test
  def setup
    se = SalesEngine.from_csv({
            :merchants     => './test/fixtures/merchants_fixtures.csv',
            :items         => './test/fixtures/items_fixtures.csv',
            :invoices      => './test/fixtures/invoices_fixtures.csv',
            :invoice_items => './test/fixtures/invoice_items_fixtures.csv',
            :transactions  => './test/fixtures/transactions_fixtures.csv',
            :customers     => './test/fixtures/customers_fixtures.csv'
            })
    @m = se.merchants.find_by_id(12334105)
  end

  def test_it_creates_a_merchant_object
    assert_equal Merchant, @m.class
  end

  def test_id_returns_id_of_merchant
    assert_equal 12334105, @m.id
  end

  def test_name_returns_name_of_merchant
    assert_equal "Shopin1901", @m.name
  end

  def test_items_returns_merchants_items
    assert_equal "Glitter scrabble frames", @m.items[0].name
    assert_equal nil, @m.items[1]
  end

  def test_invoices_returns_merchants_invoices
    invoices = @m.invoices
    assert_equal 2, invoices[0].id
    assert_equal 11, invoices[1].id
    assert_equal 12, invoices[2].id
    assert_equal 3, invoices.count
  end

  def test_customers_finds_all_merchants_customers
    assert_equal "Ondricka", @m.customers[0].last_name
    assert_equal "Osinski", @m.customers[1].last_name
    assert_equal "Toy", @m.customers[2].last_name
    assert_equal nil, @m.customers[3]
    assert_equal 3, @m.customers.count
  end

  def test_revenue_sums_revenue_of_merchants
    assert_equal 9409.36, @m.revenue.to_f
    assert_equal BigDecimal, @m.revenue.class
  end

  def test_find_invoice_items_returns_array_of_all_invoice_items_for_merchant
    assert_equal InvoiceItem, @m.invoice_items[0].class
    assert_equal 5, @m.invoice_items[0].id
  end
end
