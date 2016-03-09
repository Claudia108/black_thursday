class Invoice
  attr_reader :id, :customer_id, :merchant_id, :status,
              :created_at, :updated_at, :repository

  def initialize(invoice_hash, repository)
    @repository   = repository
    @id           = invoice_hash[:id].to_i
    @customer_id  = invoice_hash[:customer_id].to_i
    @merchant_id  = invoice_hash[:merchant_id].to_i
    @status       = invoice_hash[:status].to_sym
    @created_at   = Time.parse(invoice_hash[:created_at])
    @updated_at   = Time.parse(invoice_hash[:updated_at])
  end

  def items
    @repository.find_items(@id)
  end

  def merchant
    @repository.find_merchant(@merchant_id)
  end

  def transactions
    @repository.find_transactions(@id)
  end

  def customer
    @repository.find_customer(@customer_id)
  end

  def is_paid_in_full?
    transactions.any? { |transaction| transaction.result == "success" }
  end

  def total
    @repository.find_total(@id)
  end
end
