require 'minitest/autorun'
require 'minitest/pride'
require 'bigdecimal'
require_relative '../lib/invoice_item'
require_relative '../lib/sales_engine'

class InvoiceItemTest < Minitest::Test

  def setup
    @invoice_item = InvoiceItem.new({
      id: 1,
      item_id: 263396013,
      invoice_id: 12,
      quantity: 5,
      unit_price: 700,
      created_at: '2012-03-27 14:54:09 UTC',
      updated_at: '2012-03-27 14:54:09 UTC',
      },
      invoice_item_repository = nil)
  end

  def test_initalize_organizes_row_value_id
    assert_equal 1, @invoice_item.id
  end

  def test_initalize_organizes_row_value_item_id
    assert_equal 263396013, @invoice_item.item_id
  end

  def test_initalize_organizes_row_value_quantity
    assert_equal 5, @invoice_item.quantity
  end

  def test_initalize_organizes_row_value_unit_price
    assert @invoice_item.unit_price == 7.00
    assert_equal BigDecimal, @invoice_item.unit_price.class
  end

  def test_initalize_organizes_row_value_created_at
    assert_equal Time.parse("2012-03-27 14:54:09 UTC"), @invoice_item.created_at
  end

  def test_initalize_organizes_row_value_updated_at
    assert_equal Time.parse("2012-03-27 14:54:09 UTC"), @invoice_item.updated_at
  end

  def test_returns_price_in_dollars_formatted_as_float
    assert_equal 7.00, @invoice_item.unit_price_per_dollars
    assert_equal Float, @invoice_item.unit_price_per_dollars.class
  end
end
