require_relative 'sales_engine'
require_relative 'item'
require 'time'
require 'csv'
require 'bigdecimal'

class ItemRepository
  attr_reader :items, :sales_engine

  def initialize(value_at_item, sales_engine)
    @sales_engine = sales_engine
    make_items(value_at_item)
  end

  def inspect
    "#<#{self.class} #{@merchants.size} rows>"
  end

  def make_items(item_hashes)
    @items = item_hashes.map do |item_hash|
      Item.new(item_hash, self)
    end
  end

  def find_merchant(merchant_id)
    @sales_engine.merchants.find_by_id(merchant_id)
  end

  def all
    @items
  end

  def find_by_id(id)
    @items.find { |object| object.id == id.to_i }
  end

  def find_by_name(expected_name)
    @items.find { |object| object.name.downcase == expected_name.downcase }
  end

  def find_all_with_description(description_fragment)
    @items.find_all { |object| object.description.downcase.
                    include?(description_fragment.downcase) }
  end

  def find_all_by_price(price)
    @items.find_all { |object| object.unit_price == price }
  end

  def find_all_by_price_in_range(range)
    @items.find_all { |object| @items if range === object.unit_price }
  end

  def find_all_by_merchant_id(id)
    @items.find_all { |object| object.merchant_id == id }
  end
end
