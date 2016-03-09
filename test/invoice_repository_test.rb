require 'minitest/autorun'
require 'minitest/pride'
require 'csv'
require_relative '../lib/invoice_repository'
require_relative '../lib/sales_engine'
require_relative '../lib/invoice'

class InvoiceRepositoryTest < Minitest::Test
  def setup
    se = SalesEngine.from_csv({
            :merchants => './test/fixtures/merchants_fixtures.csv',
            :items     => './test/fixtures/items_fixtures.csv',
            :invoices   => './test/fixtures/invoices_fixtures.csv',
            :invoice_items => './test/fixtures/invoice_items_fixtures.csv',
            :transactions  => './test/fixtures/transactions_fixtures.csv',
            :customers => './test/fixtures/customers_fixtures.csv'
            })
    @ir = se.invoices
  end

  def test_find_total_returns_invoice_total
    assert_equal 7604.23, @ir.find_total(1).to_f
    assert_equal BigDecimal, @ir.find_total(1).class
  end

  def test_find_transactions_returns_invoices_transactions
    assert_equal 13, @ir.find_transactions(1)[0].id
    assert_equal nil, @ir.find_transactions(1)[1]
    assert_equal 1, @ir.find_transactions(1).count
  end

  def test_find_merchant_returns_invoices_merchant
    assert_equal "NatureDots", @ir.find_merchant(14784142).name
  end

  def test_find_items_returns_invoices_item_and_removes_nil_items
    assert_equal 263396279, @ir.find_items(1)[0].id
    assert_equal 263396255, @ir.find_items(1)[1].id
    assert_equal 263396255, @ir.find_items(1)[2].id
    assert_equal nil, @ir.find_items(1)[3]
    assert_equal 3, @ir.find_items(1).count
  end

  def test_find_customer_returns_invoices_customer
    assert_equal "Joey", @ir.find_customer(1).first_name
  end

  def test_all_returns_array_of_all_invoices
    all = @ir.all
    assert_equal 1, all[0].id
    assert_equal 2, all[1].id
    assert_equal 13, all.count
  end

  def test_find_by_id_returns_first_invoice_with_matching_id
    assert_equal 1, @ir.find_by_id(1).id
  end

  def test_find_by_id_returns_nil_if_id_does_not_exist
    assert_equal nil, @ir.find_by_id(679)
  end

  def test_find_all_by_customer_id_returns_array_of_invoices_with_matching_custy_ids
    all = @ir.find_all_by_customer_id(1)
    assert_equal 1, all[0].id
    assert_equal 2, all[1].id
    assert_equal 3, all[2].id
    assert_equal 4, all.count
  end

  def test_find_all_by_customer_id_returns_empty_array_if_id_doesnt_match
    assert_equal [], @ir.find_all_by_customer_id(143)
  end

  def test_find_all_by_merchant_id_returns_array_of_items_with_merch_id
    all = @ir.find_all_by_merchant_id(14784142)
    assert_equal 1, all[0].id
    assert_equal 4, all[1].id
    assert_equal 2, all.count
  end

  def test_find_all_by_merch_id_returns_empty_array_if_there_are_no_matches
    assert_equal [], @ir.find_all_by_merchant_id(123432324)
  end

  def test_find_all_by_status_returns_array_of_items_with_matching_status
    all = @ir.find_all_by_status(:pending)
    assert_equal :pending, all[0].status
    assert_equal :pending, all[1].status
    assert_equal :pending, all[2].status
  end

  def test_find_all_by_status_returns_empty_array_if_no_matching_status
    assert_equal [], @ir.find_all_by_status(:lozgag)
  end
end
