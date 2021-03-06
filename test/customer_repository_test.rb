require 'minitest/autorun'
require 'minitest/pride'
require_relative '../lib/customer'
require_relative '../lib/sales_engine'

class CustomerRepositoryTest < Minitest::Test
  def setup
    se = SalesEngine.from_csv({
            :merchants     => './test/fixtures/merchants_fixtures.csv',
            :items         => './test/fixtures/items_fixtures.csv',
            :invoices      => './test/fixtures/invoices_fixtures.csv',
            :invoice_items => './test/fixtures/invoice_items_fixtures.csv',
            :transactions  => './test/fixtures/transactions_fixtures.csv',
            :customers     => './test/fixtures/customers_fixtures.csv'
            })
    @cr = se.customers
  end

  def test_all_returns_array_of_all_customers
    assert_equal 3, @cr.all.count
  end
  
  def test_find_merchants_returns_customers_merchants
    assert_equal "NatureDots", @cr.find_merchants(1)[0].name
    assert_equal "Shopin1901", @cr.find_merchants(1)[1].name
    assert_equal "Candisart", @cr.find_merchants(1)[2].name
    assert_equal "MiniatureBikez", @cr.find_merchants(1)[3].name
    assert_equal nil, @cr.find_merchants(1)[4]
    assert_equal 4, @cr.find_merchants(1).count
  end

  def test_find_by_id_returns_customer_with_id
    assert_equal "Joey", @cr.find_by_id(1).first_name
  end

  def test_find_by_id_returns_nil_if_id_does_not_exist
    assert_equal nil, @cr.find_by_id(34)
  end

  def test_find_all_by_first_name_finds_name_containing_fragment_and_is_case_insensetive
    assert_equal "Joey", @cr.find_all_by_first_name("jo")[0].first_name
  end

  def test_find_all_by__first_name_returns_empty_array_if_none_match
    assert_equal [], @cr.find_all_by_first_name("jdhjhd")
  end

  def test_find_all_by_last_name_finds_name_containing_fragment_and_is_case_insensetive
    assert_equal "Ondricka", @cr.find_all_by_last_name("ndric")[0].last_name
  end

  def test_find_all_by_last_name_returns_empty_array_if_none_match
    assert_equal [], @cr.find_all_by_last_name("hde")
  end


end
