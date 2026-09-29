# app/models/order.rb
class Order
  attr_accessor :id, :user_id, :status, :total_price

  def initialize(id:, user_id:, status:, total_price:)
    @id = id
    @user_id = user_id
    @status = status # "processing", "shipped", "cancelled"
    @total_price = total_price
  end

  def cancellable?
    status == "processing"
  end

  def cancel!
    return false unless cancellable?

    @status = "cancelled"
    true
  end
end