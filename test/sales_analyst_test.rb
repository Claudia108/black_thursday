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
    assert_equal 1.21, @sa.weekday_deviation.round(2)
  end

  def test_top_days_by_invoice_count_returns_array_of_weekdays
    assert_equal nil, @sa.top_days_by_invoice_count[0]
    assert_equal 0, @sa.top_days_by_invoice_count.count
  end

  def test_invoice_status_returns_percentage_of_shipped_returned_and_pending
    assert_equal 30.77, @sa.invoice_status(:shipped)
    assert_equal 23.08, @sa.invoice_status(:returned)
    assert_equal 46.15, @sa.invoice_status(:pending)
  end

  def test_total_revenue_by_date_returns_total_revenue_for_day
    date = Time.parse("2009-12-09 00:00:00 -0700")
    assert_equal 17247.86, @sa.total_revenue_by_date(date).to_f
  end

  def test_top_revenue_earners_returns_top_20_merchants_by_default
    assert_equal "Candisart", @sa.top_revenue_earners[0].name
    assert_equal 4, @sa.top_revenue_earners.count
    #only 4 merchants in fixture
  end

  def test_top_revenue_earners_returned_sorted_array_of_merchats
    assert_equal 4, @sa.top_revenue_earners.count
  end

  def test_top_revenue_earners_returns_number_of_merchants_specified
    assert_equal "Candisart", @sa.top_revenue_earners(3)[0].name
    assert_equal 3, @sa.top_revenue_earners(3).count
  end

  def test_merchants_with_revenue_returns_array_of_sorted_merchants
    assert_equal Hash, @sa.merchants_with_revenue.class
    assert_equal 4, @sa.merchants_with_revenue.count
  end

  def test_merchants_with_pending_invoices_returns_array_of_merchants
    assert_equal "MiniatureBikez", @sa.merchants_with_pending_invoices[0].name
    assert_equal 1, @sa.merchants_with_pending_invoices.count
  end

  def test_merchants_with_only_one_item_returns_array_of_merchants
    assert_equal "Shopin1901", @sa.merchants_with_only_one_item[0].name
  end

  def test_merchants_with_only_one_item_registered_in_month_returns_array_of_merchants
    assert_equal "NatureDots", @sa.merchants_with_only_one_item_registered_in_month("June")[0].name
  end

  def test_revenue_by_merchant_finds_total_revenue_for_merchant
    assert_equal 6601.58, @sa.revenue_by_merchant(12334113).round(2)
  end

  def test_group_invoice_items
    assert_equal Hash, @sa.group_invoice_items(12334112).class
  end

  def test_find_total_quantity_reduces_invoice_quantity
    assert_equal 13, @sa.find_total_quantity_of_items_sold(12334112)[263395721]
    assert_equal 4, @sa.find_total_quantity_of_items_sold(12334112).length
  end

  # def test_find_top_invoice_item_finds_invoice_item_with_highest_quantity
  #   skip
  #   assert_equal InvoiceItem, @sa.find_top_invoice_items(12334112)[0].class
  #   assert_equal Array, @sa.find_top_invoice_items(12334112).class
  # end

  def test_most_sold_item_for_merchant_returns_array_with_item
    assert_equal Item, @sa.most_sold_item_for_merchant(12334113)[0].class
    assert_equal Array, @sa.most_sold_item_for_merchant(12334113).class
    assert_equal "Eule - Topflappen, handgehäkelt, Paar", @sa.most_sold_item_for_merchant(12334113)[0].name
  end

  def test_find_total_revenue_of_items_sold_reduces_invoice_revenue
    assert_equal 119.96, @sa.find_total_revenue_of_items_sold(12334113).values[0].to_f.round(2)
    assert_equal Hash, @sa.find_total_revenue_of_items_sold(12334113).class
  end

  def test_best_item_for_merchant
    assert_equal "Eule - Topflappen, handgehäkelt, Paar", @sa.best_item_for_merchant(12334113).name
    assert_equal Item, @sa.best_item_for_merchant(12334113).class
  end

end
