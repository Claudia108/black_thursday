require 'minitest/autorun'
require 'minitest/pride'
require 'csv'
require_relative '../lib/item_repository'
require_relative '../lib/sales_engine'

class ItemRepositoryTest < Minitest::Test
  def setup
    se = SalesEngine.from_csv({
            :merchants     => './test/fixtures/merchants_fixtures.csv',
            :items         => './test/fixtures/items_fixtures.csv',
            :invoices      => './test/fixtures/invoices_fixtures.csv',
            :invoice_items => './test/fixtures/invoice_items_fixtures.csv',
            :transactions  => './test/fixtures/transactions_fixtures.csv',
            :customers     => './test/fixtures/customers_fixtures.csv'
            })
    @ir = se.items
  end

  def test_find_merchant_returns_items_merchant
    assert_equal "MiniatureBikez", @ir.find_merchant(12334113).name
    assert_equal "NatureDots", @ir.find_merchant(14784142).name
  end

  def test_all_returns_array_of_all_items
    assert_equal Array, @ir.items.class
    assert_equal 7, @ir.all.count
  end

  def test_find_by_id_finds_items_by_id
    item = @ir.find_by_id(263395237)
    assert_equal "510+ RealPush Icon Set", item.name
    assert_equal Item, item.class
    assert_equal 263395237, item.id
  end

  def test_find_by_id_returns_nil_if_id_does_not_exist
    assert_equal nil, @ir.find_by_id(26339553243)
  end

  def test_find_by_name_finds_item_by_name
    item = @ir.find_by_name("Vogue Paris Original Givenchy 2307")
    assert_equal 263396209, item.id
    assert_equal Item, item.class
    assert_equal "Vogue Paris Original Givenchy 2307", item.name
  end

  def test_find_by_name_returns_nil_if_item_does_not_exist
    assert_equal nil, @ir.find_by_name("vVogse")
  end

  def test_find_by_name_is_case_insensitive
    item = @ir.find_by_name("VoguE paris original GivenchY 2307")
    assert_equal 263396209, item.id
    assert_equal Item, item.class
    assert_equal "Vogue Paris Original Givenchy 2307", item.name
  end

  def test_find_all_with_description_finds_items_with_description_fragment
    item = @ir.find_all_with_description("Any")
    assert_equal "510+ RealPush Icon Set", item[0].name
    assert_equal "Glitter scrabble frames", item[1].name
    assert_equal "Disney scrabble frames", item[2].name
    assert_equal "Free standing Woden letters", item[3].name
  end

  def test_find_all_with_description_is_case_insensitive
    item = @ir.find_all_with_description("flaT deSigN exceLlEnt")
    assert_equal "510+ RealPush Icon Set", item[0].name
  end

  def test_find_all_with_description_returns_empty_array_when_there_are_no_matches
    assert_equal [], @ir.find_all_with_description("fhghjdjaskj")
  end

  def test_find_all_by_price_finds_items_where_the_price_matches
    items = @ir.find_all_by_price(12.00)
    assert_equal "510+ RealPush Icon Set", items[0].name
    assert_equal "Glitter scrabble frames", items[1].name
  end

  def test_find_all_by_price_returns_empty_array_if_no_item_matches
    assert_equal [], @ir.find_all_by_price(69.00)
  end

  def test_find_all_by_price_in_range_finds_items_by_given_price_range
    items = @ir.find_all_by_price_in_range(12.00..13.00)
    assert_equal "510+ RealPush Icon Set", items[0].name
    assert_equal "Glitter scrabble frames", items[1].name
  end

  def test_find_all_by_price_in_range_returns_empty_array_if_no_item_matches
    assert_equal [], @ir.find_all_by_price_in_range(1.00..5.00)
  end

  def test_find_all_by_merchant_id_finds_items_by_given_merchant_id
    items = @ir.find_all_by_merchant_id(12334113)
    assert_equal "Vogue Paris Original Givenchy 2307", items[0].name
    assert_equal "Cache cache à la plage", items[1].name
  end

  def test_find_all_by_merchant_id_returns_empty_array_if_no_item_matches
    assert_equal [], @ir.find_all_by_merchant_id(100000)
  end
end
