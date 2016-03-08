require 'pry'
require_relative 'sales_engine'
class SalesAnalyst
  def initialize(se)
    @se = se
    @mr = @se.merchants
    @ir = @se.items
    @invr = @se.invoices
    @cr = @se.customers
    @initr = @se.invoice_items
  end

  def top_buyers(number=20)
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

  def item_count_deviation(item_count)
    # sum = item_count.reduce(0) do |sum, count|
    #   sum + ((count - average_items_per_merchant) ** 2)
    # end
    # deviation = Math.sqrt(sum / (@mr.all.count - 1)).round(2)
    compute_deviation(@mr, item_count, average_items_per_merchant)
  end

  def compute_deviation(repository, elements, average)
    sum = elements.reduce(0) do |sum, element|
      sum + ((element - average) ** 2)
    end
    deviation = Math.sqrt(sum / (repository.all.count - 1)).round(2)
  end

  def price_deviation
    # sum = find_all_item_prices.reduce(0) do |sum, price|
    #   sum + ((price - average_average_price_per_merchant) ** 2)
    # end
    compute_deviation(@ir, find_all_item_prices, average_average_price_per_merchant)
    # deviation = Math.sqrt(sum / (@ir.all.count - 1)).round(2)
  end

  def average_invoices_per_merchant_standard_deviation
    # sum = all_invoices_per_merchant.reduce(0) do |sum, count|
    #   sum + ((count - average_invoices_per_merchant) ** 2)
    # end
    compute_deviation(@mr, all_invoices_per_merchant, average_invoices_per_merchant)
    # deviation = Math.sqrt(sum / (@mr.all.count - 1).to_f).round(2)
  end

  def weekday_deviation
    day_average = (@invr.all.count / 7.00)
    compute_deviation(@invr, weekday_count, day_average)
    # sum = weekday_count.reduce(0) do |sum, day|
    #   sum += ((day[1] - (@invr.all.count / 7.00)) ** 2)
    # end
    # Math.sqrt(sum / (@invr.all.count - 1).to_f)
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

    def top_days_by_invoice_count
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


    def invoice_status(status)
      count = @invr.all.count { |invoice| invoice.status == status }
      ((count.to_f / @invr.all.count.to_f) * 100).round(2)
    end

    def top_buyers(count = 20)
      sorted = sum_invoices_for_customers.sort_by { |customer, total| total }
      customers = sorted.map(&:last) #{ |customer_and_total| customer_and_total[0] }
      # binding.pry
      customers[(-count + 1)..-1]
    end

    def connect_customers_and_invoices
      customer_invoices = {}
      @cr.all.each do |customer|
        customer_invoices[customer] = customer.invoices
      end
      customer_invoices
    end
  def select_paid_invoices
    paid_customer_invoices = {}
    connect_customers_and_invoices.each do |customer, invoices|
      paid_invoices = invoices.find_all { |invoice| invoice.is_paid_in_full? }
      paid_customer_invoices[customer] = paid_invoices
    end
  end

  def sum_invoices_for_customers
    select_paid_invoices.reduce(Hash.new(0)) do |memo, customer_and_invoices|
      customer = customer_and_invoices.first
      invoices = customer_and_invoices.last
      memo[customer] = compute_invoice_totals(invoices)
      memo
    end
  end

  def compute_invoice_totals(invoices)
    invoices.map do |invoice|
      invoice = invoice.total
    end.reduce(0, :+)
  end

  def one_time_buyers
    one_timers = []
    connect_customers_and_invoices.each do |customer, invoices|
      if invoices.count == 1
        one_timers << customer
      end
    end
    one_timers
  end

  def one_time_buyers_item
    invoice = one_time_buyers.map do |customer|
      customer.invoices
    end
    items = invoice[0][0].items
    items.flatten
  end

  def customers_with_unpaid_invoices
    unpaid_invoices = @invr.all.find_all { |invoice| invoice.is_paid_in_full? == false}
    customers = unpaid_invoices.map do |invoice|
      invoice.customer
    end
    customers.compact
  end

  def best_invoice_by_revenue
    paid_invoices = @invr.all.find_all { |invoice| invoice.is_paid_in_full? }
    paid_invoices.max_by { |invoice| invoice.total }
  end

  # def best_invoice_by_quantity
  #   paid_invoices = @invr.all.find_all { |invoice| invoice.is_paid_in_full? }
  #   invoice_items = paid_invoices.map { |invoice| @initr.find_all_by_invoice_id(invoice.id) }
  #   invoice_items.map { |invoice_item| invoice_item.quantity }
  # end

  def top_merchant_for_customer(customer_id)
    sorted = find_merchants_items_quantity(customer_id).sort_by { |k,v| v }
    sorted[-1][0]
  end

  def group_invoices_by_merchant(customer_id)
    customer = @cr.find_by_id(customer_id)
    merchants = customer.merchants
    merchant_invoices = merchants.reduce(Hash.new(0)) do |memo, merchant|
      memo[merchant] = merchant.invoices
      memo
    end
  end

  def find_invoices_from_customer(customer_id)
    customers_merchants_invoices = {}
    group_invoices_by_merchant(customer_id).each do |merchant, invoices|
      customers_merchants_invoices[merchant] = invoices.find_all { |invoice| invoice.customer_id == customer_id }
    end
  end

  def find_merchants_invoice_items(customer_id)
    customers_merchants_invoice_items = {}
    find_invoices_from_customer(customer_id).each do |merchant, invoices|
      customers_merchants_invoice_items[merchant] = (invoices.map { |invoice| @initr.find_all_by_invoice_id(invoice.id) }).flatten
    end
    customers_merchants_invoice_items
  end

  def find_merchants_items_quantity(customer_id)
    customer_merchants_items_quantity = {}
    find_merchants_invoice_items(customer_id).each do |merchant, invoice_items|
      customer_merchants_items_quantity[merchant] = invoice_items.reduce(0) { |sum, invoice_item| sum += invoice_item.quantity }
    end
    customer_merchants_items_quantity
  end



end
