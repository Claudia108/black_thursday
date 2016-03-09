require 'pry'
require_relative 'sales_engine'

class SalesAnalyst
  def initialize(se)
    @se   = se
    @mr   = @se.merchants
    @ir   = @se.items
    @invr = @se.invoices
    @merchant_ids = @mr.all.map { |merchant| merchant.id }
  end

  def compute_deviation(repository, elements, average)
    sum = elements.reduce(0) do |sum, element|
      sum + ((element - average) ** 2)
    end
    deviation = Math.sqrt(sum / (repository.all.count - 1)).round(2)
  end

  def average_items_per_merchant
    (@ir.all.count.to_f / @mr.all.count.to_f).round(2)
  end

  def average_items_per_merchant_standard_deviation
    item_count = @merchant_ids.map do |id|
      @mr.find_items(id).count
    end
    item_count_deviation(item_count)
  end

  def item_count_deviation(item_count)
    compute_deviation(@mr, item_count, average_items_per_merchant)
  end

  def merchants_with_high_item_count
    threshold = average_items_per_merchant +
                average_items_per_merchant_standard_deviation
    @merchant_ids.map do |id|
      item_count = @mr.find_items(id).count
      @mr.find_by_id(id) if item_count > threshold
    end.compact
  end

  def average_item_price_for_merchant(id)
    items = @mr.find_items(id)
    prices = items.map do |item|
      item.unit_price
    end
    (prices.reduce(:+)/items.count).round(2)
  end

  def average_average_price_per_merchant
    prices = @merchant_ids.reduce(0) do |sum, id|
      sum += average_item_price_for_merchant(id)
    end
    (prices / @merchant_ids.count).round(2)
  end

  def golden_items
    p_deviation = (price_deviation * 2) + average_average_price_per_merchant
    @ir.all.find_all do |item|
      item.unit_price >= p_deviation
    end
  end

  def find_all_item_prices
    @ir.all.map { |item| item.unit_price }
  end

  def price_deviation
    compute_deviation(@ir, find_all_item_prices,
                      average_average_price_per_merchant)
  end

  def average_invoices_per_merchant
    (@invr.all.count.to_f / @mr.all.count.to_f).round(2)
  end

  def all_invoices_per_merchant
    @mr.all.map { |merchant| merchant.invoices.count}
  end

  def average_invoices_per_merchant_standard_deviation
    compute_deviation(@mr, all_invoices_per_merchant,
                      average_invoices_per_merchant)
  end

  def top_merchants_by_invoice_count
    threshold = average_invoices_per_merchant +
                (average_invoices_per_merchant_standard_deviation * 2)
    @merchant_ids.map do |merchant_id|
      invoice_count = @invr.find_all_by_merchant_id(merchant_id).count
      @mr.find_by_id(merchant_id) if invoice_count > threshold
    end.compact
  end

  def bottom_merchants_by_invoice_count
    threshold = average_invoices_per_merchant -
                (average_invoices_per_merchant_standard_deviation * 2)
    @merchant_ids.map do |merchant_id|
      invoice_count = @invr.find_all_by_merchant_id(merchant_id).count
      @mr.find_by_id(merchant_id) if invoice_count < threshold
    end.compact
  end

  def weekday_count
    wd = @invr.all.map { |invoice| invoice.created_at.to_date.strftime('%A') }
    weekday_count = wd.reduce(Hash.new(0)) do |hash, weekday|
      hash[weekday] += 1
      hash
    end
  end

  def top_days_by_invoice_count
    threshold = (@invr.all.count / 7 ) + weekday_deviation
    weekday_count.map do |key, value|
      key if value > threshold
    end.compact
  end

  def weekday_deviation
    sum = weekday_count.reduce(0) do |sum, day|
      sum += ((day[1] - (@invr.all.count / 7.00)) ** 2)
    end
    Math.sqrt(sum / 6)
  end

  def invoice_status(status)
    count = @invr.all.count { |invoice| invoice.status == status }
    ((count / @invr.all.count.to_f) * 100).round(2)
  end

  def total_revenue_by_date(date)
    invoices = @invr.all.select { |invoice| invoice.created_at == date }
    invoices.reduce(0) { |sum, invoice| sum += invoice.total }
  end

  def top_revenue_earners(count=20)
    sorted = merchants_with_revenue.max_by(count) {|merchant, revenue| revenue }
    sorted.map(&:first)
  end

  def merchants_ranked_by_revenue
    top_revenue_earners(99999)
  end

  def merchants_with_revenue
    merchants = @mr.all.reduce(Hash.new(0)) do |memo, merchant|
      memo[merchant] = merchant.revenue
      memo
    end
  end

  def merchants_with_pending_invoices
    @mr.all.select do |merchant|
      merchant.invoices.any? { |invoice| invoice.is_paid_in_full? == false }
    end
  end

  def merchants_with_only_one_item
    @mr.all.select { |merchant| merchant.items.count == 1 }
  end

  def merchants_with_only_one_item_registered_in_month(month)
    merchants_from_month = @mr.all.find_all do |merchant|
      merchant.created_at.strftime("%B") == month
    end
    merchants_from_month.select { |merchant| merchant.items.count == 1 }
  end

  def revenue_by_merchant(merchant_id)
    @mr.find_by_id(merchant_id).revenue
  end

  def group_invoice_items(merchant_id)
    invoice_items = @mr.find_by_id(merchant_id).invoice_items
    invoice_items.group_by { |invoice_item| invoice_item.item_id }
  end

  def find_total_quantity_of_items_sold(merchant_id)
    item_quantity = {}
    group_invoice_items(merchant_id).each do |item_id, invoice_items|
      item_quantity[item_id] = invoice_items.reduce(0) do |sum, invoice_item|
      sum += invoice_item.quantity
      end
    end
    item_quantity
  end

  def most_sold_item_for_merchant(merchant_id)
    sort_items(find_total_quantity_of_items_sold(merchant_id))
  end

  def sort_items(items)
    top = items.max_by { |item, value| value }
    top_items = items.find_all { |item, value| value == top[1] }
    top_items.map { |item_array| @ir.find_by_id(item_array[0]) }
  end

  def best_item_for_merchant(merchant_id)
    sort_items(find_total_revenue_of_items_sold(merchant_id)).pop
  end

  def find_total_revenue_of_items_sold(merchant_id)
    item_revenue = {}
    items = group_invoice_items(merchant_id).each do |item_id, invoice_items|
      item_revenue[item_id] = invoice_items.reduce(0) do |sum, invoice_item|
      sum += (invoice_item.quantity * invoice_item.unit_price)
      end
    end
    item_revenue
  end

end
