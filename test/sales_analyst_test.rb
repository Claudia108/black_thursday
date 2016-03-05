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
    @mr = se.merchants
    @sa = SalesAnalyst.new(se)
  end

  def test_average_items_per_merchant_returns_float
    assert_equal  1.75, @sa.average_items_per_merchant
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
    assert_equal 3.0, @sa.average_invoices_per_merchant
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
    assert_equal 0.82, @sa.average_invoices_per_merchant_standard_deviation
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
    assert_equal 6, @sa.weekday_count.count
    assert_equal 1, @sa.weekday_count["Sunday"]
    assert_equal 3, @sa.weekday_count["Monday"]
    assert_equal 1, @sa.weekday_count["Tuesday"]
    assert_equal 1, @sa.weekday_count["Wednesday"]
    assert_equal 4, @sa.weekday_count["Friday"]
    assert_equal 2, @sa.weekday_count["Saturday"]
  end

  def test_weekday_deviation_returns_deviation_of_invoices_per_day
    assert_equal 1.13, @sa.weekday_deviation
  end

  def test_top_days_by_invoice_count_returns_array_of_weekdays
    assert_equal "Friday", @sa.top_days_by_invoice_count[0]
    assert_equal "Monday", @sa.top_days_by_invoice_count[1]
    assert_equal nil, @sa.top_days_by_invoice_count[2]
    assert_equal 2, @sa.top_days_by_invoice_count.count
  end

  def test_invoice_status_returns_percentage_of_shipped_returned_and_pending
    assert_equal 33.33, @sa.invoice_status(:shipped)
    assert_equal 16.67, @sa.invoice_status(:returned)
    assert_equal 50.0, @sa.invoice_status(:pending)
  end

end
