require 'minitest/autorun'
require 'minitest/pride'
require 'csv'
require 'time'
require 'pry'
require_relative '../lib/transaction'
require_relative '../lib/sales_engine'

class TransactionTest < Minitest::Test

  def setup
      se = SalesEngine.from_csv({
              :merchants     => './test/fixtures/merchants_fixtures.csv',
              :items         => './test/fixtures/items_fixtures.csv',
              :invoices      => './test/fixtures/invoices_fixtures.csv',
              :invoice_items => './test/fixtures/invoice_items_fixtures.csv',
              :transactions  => './test/fixtures/transactions_fixtures.csv',
              :customers => './test/fixtures/customers_fixtures.csv'
              })
      tr = se.transactions
      @transaction = tr.find_by_id(1)
  end

  def test_initalize_organizes_row_value_id
    assert_equal 1, @transaction.id
  end

  def test_initalize_organizes_row_value_invoice_id
    assert_equal 2, @transaction.invoice_id
  end

  def test_initalize_organizes_row_value_credit_card_number
    assert_equal 4068631943231473, @transaction.credit_card_number
  end

  def test_initalize_organizes_row_value_credit_card_expiration_date
    assert_equal "0217", @transaction.credit_card_expiration_date
  end

  def test_initalize_organizes_row_value_result
    assert_equal "success", @transaction.result
  end

  def test_initalize_organizes_row_value_created_at
    assert_equal Time.parse("2012-02-26 20:56:56 UTC"), @transaction.created_at
  end

  def test_initalize_organizes_row_value_updated_at
    assert_equal Time.parse("2012-02-26 20:56:56 UTC"), @transaction.updated_at
  end

  def test_invoice_finds_transaction_invoice
    assert_equal 2, @transaction.invoice.id
  end
end
