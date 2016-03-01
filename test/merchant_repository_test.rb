require 'minitest/autorun'
require 'minitest/pride'
require '../lib/merchant_repository'

class MerchantRepositoryTest < Minitest::Test
  def setup
    mc = MerchantRepository.new
    m = Merchant.new({:id => 5, :name => "Turing School"})
  end

end
