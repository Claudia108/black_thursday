require 'pry'
require_relative "transaction"
require_relative "sales_engine"
require 'csv'

class TransactionRepository
  attr_reader :sales_engine, :transactions

  def initialize(transactions_data, sales_engine)
    @sales_engine = sales_engine
    make_transactions(transactions_data)
  end

  def inspect
    "#<#{self.class} #{@transactions.size} rows>"
  end

  def make_transactions(transaction_hashes)
    @transactions = transaction_hashes.map do |transaction_hash|
      Transaction.new(transaction_hash, self)
    end
  end

  def find_invoice(invoice_id)
    @sales_engine.invoices.find_by_id(invoice_id)
  end

  def all
    @transactions
  end

  def find_by_id(id)
    @transactions.find { |object| object.id == id }
  end

  def find_all_by_invoice_id(id)
    @transactions.find_all { |object| object.invoice_id == id }
  end

  def find_all_by_credit_card_number(number)
    @transactions.find_all { |object| object.credit_card_number == number }
  end

  def find_all_by_result(result)
    @transactions.find_all { |object| object.result == result }
  end
end
