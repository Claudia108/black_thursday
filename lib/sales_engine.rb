require_relative 'merchant_repository'
require_relative 'item_repository'
require_relative 'invoice_repository'
require_relative 'customer_repository'
require_relative 'invoice_item_repository'
require_relative 'transaction_repository'
require_relative 'sales_analyst'
require 'csv'
require 'pry'

class SalesEngine
  attr_reader :data, :merchants, :items, :invoices, :customers,
              :invoice_items, :transactions, :sales_analyst

  def initialize(data={})
    @data             = data
    @merchants        = MerchantRepository.new(@data[:merchants], self)
    @items            = ItemRepository.new(@data[:items], self)
    @invoices         = InvoiceRepository.new(@data[:invoices], self)
    @invoice_items    = InvoiceItemRepository.new(@data[:invoice_items], self)
    @transactions     = TransactionRepository.new(@data[:transactions], self)
    @customers        = CustomerRepository.new(@data[:customers], self)
    @sales_analyst    = SalesAnalyst.new(self)
  end

  def self.from_csv(data)
    csv_content = data.reduce(Hash.new(0)) do |memo, data|
      memo[data[0]] = CSV.read(data[1], headers: true, header_converters: :symbol)
      memo
    end
    SalesEngine.new(csv_content)
  end
end
