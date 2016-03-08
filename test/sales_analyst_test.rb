require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/merchant_repository'
require_relative '../lib/item_repository'
require_relative '../lib/sales_engine'

class SalesAnalystTest < Minitest::Test
  def setup
    se = SalesEngine.from_csv({
            :merchants     => './fixtures/merchants_fixtures.csv',
            :items         => './fixtures/items_fixtures.csv',
            :invoices      => './fixtures/invoices_fixtures.csv',
            :invoice_items => './fixtures/invoice_items_fixtures.csv',
            :transactions  => './fixtures/transactions_fixtures.csv',
            :customers => './fixtures/customers_fixtures.csv'
            })
    @customer = se.customers.find_by_id(1)
    @sa = SalesAnalyst.new(se)
  end

  def test_average_items_per_merchant_returns_float
    assert_equal 1.75, @sa.average_items_per_merchant
  end

  def test_average_items_per_merchant_standard_deviation
    assert_equal 0.96, @sa.average_items_per_merchant_standard_deviation
  end

  def test_merchants_with_high_item_count
    assert_equal "MiniatureBikez", @sa.merchants_with_high_item_count[0].name
    assert_equal nil, @sa.merchants_with_high_item_count[1]
  end

  def test_average_item_price_for_merchant
    assert_equal 64.63, @sa.average_item_price_for_merchant(12334113).to_f
    assert_equal BigDecimal, @sa.average_item_price_for_merchant(12334113).class
  end

  def test_average_average_price_per_merchant_returns_average_price_of_all_items
    assert_equal 24.72, @sa.average_average_price_per_merchant.to_f
    assert_equal BigDecimal, @sa.average_average_price_per_merchant.class
  end

  def test_price_deviation_returns_price_deviation_for_all_items
    @sa.find_all_item_prices
    assert_equal 52.17, @sa.price_deviation
  end

  def test_golden_items_returns_items_that_are_two_standard_deviations_above_average
    assert_equal "Cache cache à la plage", @sa.golden_items[0].name
    assert_equal nil, @sa.golden_items[1]
  end

  def test_average_invoices_per_merchant_returns_average
    assert_equal 3.25, @sa.average_invoices_per_merchant
  end

  def test_all_invoices_per_merchant_returns_matching_invoice_count
    assert_equal 3, @sa.all_invoices_per_merchant[0]
    assert_equal 3, @sa.all_invoices_per_merchant[1]
    assert_equal 4, @sa.all_invoices_per_merchant[2]
    assert_equal 2, @sa.all_invoices_per_merchant[3]
    assert_equal nil, @sa.all_invoices_per_merchant[4]
    assert_equal 4, @sa.all_invoices_per_merchant.count
  end

  def test_average_invoices_per_merchant_standard_deviation_returns_average
    assert_equal 0.87, @sa.average_invoices_per_merchant_standard_deviation
  end

  def test_top_merchants_by_invoice_count_returns_array_of_top_merchants
    assert_equal nil, @sa.top_merchants_by_invoice_count[0]
    assert_equal 0, @sa.top_merchants_by_invoice_count.count
  end

  def test_bottom_merchants_by_invoice_count_returns_array_of_bottom_merchants
    assert_equal nil, @sa.bottom_merchants_by_invoice_count[0]
    assert_equal 0, @sa.bottom_merchants_by_invoice_count.count
  end

  def test_weekdays_builds_hash_with_counts
    assert_equal 7, @sa.weekday_count.count
    assert_equal 1, @sa.weekday_count["Sunday"]
    assert_equal 3, @sa.weekday_count["Monday"]
    assert_equal 1, @sa.weekday_count["Tuesday"]
    assert_equal 1, @sa.weekday_count["Wednesday"]
    assert_equal 1, @sa.weekday_count["Thursday"]
    assert_equal 4, @sa.weekday_count["Friday"]
    assert_equal 2, @sa.weekday_count["Saturday"]
  end

  def test_weekday_deviation_returns_deviation_of_invoices_per_day
#thursday invoice inserted to fixture
    assert_equal 0.86, @sa.weekday_deviation.round(2)
  end

  def test_top_days_by_invoice_count_returns_array_of_weekdays
    assert_equal "Friday", @sa.top_days_by_invoice_count[0]
    assert_equal "Monday", @sa.top_days_by_invoice_count[1]
    assert_equal nil, @sa.top_days_by_invoice_count[2]
    assert_equal 2, @sa.top_days_by_invoice_count.count
  end

  def test_invoice_status_returns_percentage_of_shipped_returned_and_pending
    assert_equal 30.77, @sa.invoice_status(:shipped)
    assert_equal 23.08, @sa.invoice_status(:returned)
    assert_equal 46.15, @sa.invoice_status(:pending)
  end

  def test_top_buyers_returns_20_buyers_who_spent_the_most
    skip
    se = SalesEngine.from_csv({
            :merchants     => '../data/merchants.csv',
            :items         => '../data/items.csv',
            :invoices      => '../data/invoices.csv',
            :invoice_items => '../data/invoice_items.csv',
            :transactions  => '../data/transactions.csv',
            :customers     => '../data/customers.csv'
            })
    sa = SalesAnalyst.new(se)
    customer = se.customers.find_by_id(1)
    assert_equal 20, sa.top_buyers.count
    assert_equal BigDecimal, sa.top_buyers[customer].class
  end

  def test_connect_customers_and_invoices_builds_hash_with_customers_pointing_to_invoices
    skip
    assert_equal Array, @sa.connect_customers_and_invoices[@customer].class
    assert_equal Invoice, @sa.connect_customers_and_invoices[@customer][0].class
    assert_equal 1, @sa.connect_customers_and_invoices[@customer][0].id
  end

  def test_find_invoice_items_replaces_invoices_with_invoice_items
    skip
    assert_equal Array, @sa.find_invoice_items.class
    assert_equal Array, @sa.find_invoice_items[0].class
    assert_equal Array, @sa.find_invoice_items[0][0].class
    assert_equal InvoiceItem, @sa.find_invoice_items[0][0][0].class
  end

  def test_connect_customers_and_invoices_builds_hash_with_customers_pointing_to_invoices
    assert_equal Hash, @sa.connect_customers_and_invoices.class
    assert_equal Customer, @sa.connect_customers_and_invoices.keys[0].class
    assert_equal Array, @sa.connect_customers_and_invoices.values[0].class
    assert_equal Invoice, @sa.connect_customers_and_invoices.values[0][0].class
  end

  def test_sum_invoices_for_customers_returns_total_spent_per_customer
    assert_equal Hash, @sa.sum_invoices_for_customers.class
    assert_equal 1580.18, @sa.sum_invoices_for_customers.values[1].to_f.round(2)
  end

  def test_top_buyers_returns_number_of_buyers_designated
    assert_equal 2, @sa.top_buyers(2).count
  end

end
