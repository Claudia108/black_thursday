require 'minitest/autorun'
require 'minitest/pride'
require '../lib/merchant'
require '../lib/merchant_repository'
require '../lib/item'
require '../lib/item_repository'
require '../sales_engine'

class MerchantTest < Minitest::Test
  def setup
    se = SalesEngine.from_csv({
            :merchants => './fixtures/merchants_fixtures.csv',
            :items     => './fixtures/items_fixtures.csv'
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

  def test_items_returns_of_merchants_items
    assert_equal "", @m.items[0].name
    assert_equal "", @m.items[1].name

    # merchants id, match with merchants id in items files
    # array of item objects
  end

end