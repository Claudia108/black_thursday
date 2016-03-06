require 'pry'
require_relative 'sales_engine'
class SalesAnalyst
  def initialize(se)
    @se = se
    @mr = @se.merchants
    @ir = @se.items
    @invr = @se.invoices
  end

  def average_items_per_merchant
    (@ir.all.count.to_f / @mr.all.count.to_f).round(2)

    #can ask item repo for items.count and merch repo merchants.count
    # merchant_ids = @mr.all.map { |merchant| merchant.id }
    # total_items = merchant_ids.reduce(0) do |sum, id|
    #   sum += @mr.find_items(id).count
    # end
    # (total_items/@mr.merchants.count.to_f).round(2)
  end

  def average_items_per_merchant_standard_deviation
    merchant_ids = @mr.all.map { |merchant| merchant.id }
    item_count = merchant_ids.map do |id|
      @mr.find_items(id).count
    end
    item_count_deviation(item_count)
  end

  def item_count_deviation(item_count)
    sum = item_count.reduce(0) do |sum, count|
      sum + ((count - average_items_per_merchant) ** 2)
    end
    deviation = Math.sqrt(sum / (@mr.all.count - 1)).round(2)
  end

  def merchants_with_high_item_count
    #how can we use map if nil gets returned when threshold isnt met
    threshold = average_items_per_merchant + average_items_per_merchant_standard_deviation
    merchant_ids = @mr.all.map { |merchant| merchant.id }
    golden_merchants = []
    merchant_ids.each do |id|
      item_count = @mr.find_items(id).count
      if item_count > threshold
        golden_merchants << @mr.find_by_id(id)
      end
    end
    golden_merchants
  end

  def average_item_price_for_merchant(id)
    items = @mr.find_items(id)
    prices = items.map do |item|
      item.unit_price
    end
    (prices.reduce(:+)/items.count).round(2)
  end

  def average_average_price_per_merchant
    merchants_ids = @mr.all.map { |merchant| merchant.id }
    prices = merchants_ids.reduce(0) do |sum, id|
      sum += average_item_price_for_merchant(id)
    end
    (prices / merchants_ids.count).round(2)
  end

  def golden_items
    p_deviation = (price_deviation * 2) + average_average_price_per_merchant
    @ir.all.find_all do |item|
      item.unit_price >= p_deviation
    end
  end

  def find_all_item_prices
    @ir.all.map { |item| item.unit_price }
    # merchant_ids = @mr.all.map { |merchant| merchant.id }
    # item_prices = merchant_ids.map do |id|
    #   prices = @mr.find_items(id).map do |item|
    #     item.unit_price
    #   end
    # end
    # item_prices.flatten
  end

  def price_deviation
    sum = find_all_item_prices.reduce(0) do |sum, price|
      sum + ((price - average_average_price_per_merchant) ** 2)
    end
    deviation = Math.sqrt(sum / (@ir.all.count - 1)).round(2)
  end

  def average_invoices_per_merchant
    (@invr.all.count.to_f / @mr.all.count.to_f).round(2)

    # merchant_ids = @mr.all.map { |merchant| merchant.id }
    # invoice_count = merchant_ids.reduce(0) do |sum, merchant_id|
    #   sum += @invr.find_all_by_merchant_id(merchant_id).count
    #   sum
    #   # binding.pry
    # end
    # (invoice_count/@mr.merchants.count.to_f).round(2)
  end

  def all_invoices_per_merchant
    @mr.all.map { |merchant| merchant.invoices.count}
  end

  def average_invoices_per_merchant_standard_deviation
    sum = all_invoices_per_merchant.reduce(0) do |sum, count|
      sum + ((count - average_invoices_per_merchant) ** 2)
    end
    deviation = Math.sqrt(sum / (@mr.all.count - 1).to_f).round(2)
  end

  def top_merchants_by_invoice_count
    threshold = average_invoices_per_merchant + (average_invoices_per_merchant_standard_deviation * 2)
    merchant_ids = @mr.all.map { |merchant| merchant.id }
      top_merchants = []
      merchant_ids.each do |merchant_id|
        invoice_count = @invr.find_all_by_merchant_id(merchant_id).count
        if invoice_count > threshold
          top_merchants << @mr.find_by_id(merchant_id)
        end
      end
      top_merchants
  end

  def bottom_merchants_by_invoice_count
    threshold = average_invoices_per_merchant - (average_invoices_per_merchant_standard_deviation * 2)
    merchant_ids = @mr.all.map { |merchant| merchant.id }
    top_merchants = []
    merchant_ids.each do |merchant_id|
      invoice_count = @invr.find_all_by_merchant_id(merchant_id).count
      top_merchants << @mr.find_by_id(merchant_id) if invoice_count < threshold
    end
    top_merchants
  end


  def weekday_count
    @weekdays = @invr.all.map { |invoice| invoice.created_at.to_date.strftime('%A') }
    weekday_count = @weekdays.reduce(Hash.new(0)) do |hash, weekday|
      # hash[weekday] ||= 0
      hash[weekday] += 1
      hash
    end
  end

    def  top_days_by_invoice_count
      weekday_count
      threshold = (@invr.all.count / 7.00) + weekday_deviation
      top_days = []
      weekday_count.each do |key, value|
        if value > threshold
          top_days << key
        end
      end
      top_days
    end

    def weekday_deviation
      sum = weekday_count.reduce(0) do |sum, day|
        sum += ((day[1] - (@invr.all.count / 7.00)) ** 2)
      end
      Math.sqrt(sum / (@invr.all.count - 1).to_f)
    end

    def invoice_status(status)
      count = @invr.all.count { |invoice| invoice.status == status }
      ((count.to_f / @invr.all.count.to_f) * 100).round(2)
    end

end
