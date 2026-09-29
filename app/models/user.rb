# app/models/user.rb
class User
  attr_reader :id, :name, :orders

  def initialize(id:, name:, orders: [])
    @id = id
    @name = name
    @orders = orders
  end

  # Безопасный поиск заказа строго в рамках коллекции пользователя
  def find_order(order_id)
    orders.find { |o| o.id == order_id.to_i }
  end
end