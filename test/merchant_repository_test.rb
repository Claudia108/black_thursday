require 'minitest/autorun'
require 'minitest/pride'
require 'csv'
require 'pry'
require_relative '../lib/merchant_repository'
require_relative '../lib/merchant'
require_relative '../lib/sales_engine'

class MerchantRepositoryTest < Minitest::Test
  #don't forget csv has created_at and updated_at
  def setup
     se = SalesEngine.from_csv({
                :merchants => './fixtures/merchants_fixtures.csv',
                :items     => './fixtures/items_fixtures.csv',
                :invoices      => './fixtures/invoices_fixtures.csv',
                :invoice_items => './fixtures/invoice_items_fixtures.csv',
                :transactions  => './fixtures/transactions_fixtures.csv',
                :customers => './fixtures/customers_fixtures.csv'
                })
     @mr = se.merchants
  end

  def test_all_returns_array_of_all_merchants
    assert_equal Array, @mr.merchants.class
    assert_equal 4, @mr.all.count
  end

  def test_find_by_id_returns_merchant_object
    merchant = @mr.find_by_id(12334113)
    assert_equal "MiniatureBikez", merchant.name
    assert_equal Merchant, merchant.class
    assert_equal 12334113, merchant.id
  end

  def test_find_by_id_returns_nil_when_id_doesnt_exist
    assert_equal nil, @mr.find_by_id(123344342)
  end

  def test_find_by_name_finds_first_merchant
      merchant = @mr.find_by_name("MiniatureBikez")
      assert_equal 12334113, merchant.id
      assert_equal Merchant, merchant.class
      assert_equal "MiniatureBikez", merchant.name
  end

  def test_find_by_name_returns_nil_when_name_doesnt_exist
    assert_equal nil, @mr.find_by_name("lolz")
  end

  def test_find_by_name_is_case_insensitive
    merchant = @mr.find_by_name("CANDIsarT")
    assert_equal 12334112, merchant.id
  end

  def test_find_all_by_name_finds_all_merchants_with_name_fragment
    merchants = @mr.find_all_by_name("ture")

    assert_equal "MiniatureBikez", merchants[0].name
    assert_equal "NatureDots", merchants[1].name
  end

  def test_find_by_name_returns_empty_array_if_fragment_not_found
    merchants = @mr.find_all_by_name("hgfdse")

    assert_equal [], merchants
  end

  def test_find_invoices_returns_merchants_invoices
    assert_equal 2, @mr.find_invoices(12334105)[0].id
    assert_equal 11, @mr.find_invoices(12334105)[1].id
    assert_equal 12, @mr.find_invoices(12334105)[2].id
    assert_equal nil, @mr.find_invoices(12334105)[3]
    assert_equal 3, @mr.find_invoices(12334105).count
  end

  def test_find_items_returns_merchants_items
    assert_equal 'Glitter scrabble frames', @mr.find_items(12334105)[0].name
    assert_equal nil, @mr.find_items(12334105)[1]
    assert_equal 1, @mr.find_items(12334105).count
  end

  def test_find_customers_returns_merchants_customers
    assert_equal "Ondricka", @mr.find_customers(12334105)[0].last_name
    assert_equal "Osinski", @mr.find_customers(12334105)[1].last_name
    assert_equal "Toy", @mr.find_customers(12334105)[2].last_name
    assert_equal nil, @mr.find_customers(12334105)[3]
    assert_equal 3, @mr.find_customers(12334105).count
  end

  def test_find_invoice_items_returns_array_of_all_invoice_items_for_merchant
    assert_equal InvoiceItem, @mr.find_paid_invoice_items(12334112)[0].class
    assert_equal 2, @mr.find_paid_invoice_items(12334112)[0].id
  end

end
