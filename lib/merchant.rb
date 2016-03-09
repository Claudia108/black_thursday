class Merchant
  attr_reader :id, :name, :repository, :created_at

  def initialize(merchant_hash, repository)
    @repository = repository
    @id         = merchant_hash[:id].to_i
    @name       = merchant_hash[:name]
    @created_at = Time.parse(merchant_hash[:created_at])
  end

  def items
    @repository.find_items(@id)
  end

  def invoices
    @repository.find_invoices(@id)
  end

  def customers
    @repository.find_customers(@id)
  end

  def invoice_items
    @repository.find_paid_invoice_items(@id)
  end

  def revenue
    invoice_items.reduce(0) do |sum, invoice_item|
      sum += invoice_item.quantity * invoice_item.unit_price
    end
  end
end
