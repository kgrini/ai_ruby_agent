# main.rb
require_relative 'app/models/order'
require_relative 'app/models/user'
require_relative 'app/services/ai/agent_runner'

# Подготовка тестовых данных
order1 = Order.new(id: 101, user_id: 1, status: "shipped", total_price: 150)
order2 = Order.new(id: 102, user_id: 1, status: "processing", total_price: 80)

# Пользователь Иван имеет доступ ТОЛЬКО к заказам #101 и #102
user = User.new(id: 1, name: "Иван", orders: [order1, order2])

# Создаем агента для Ивана
agent = Ai::AgentRunner.new(current_user: user)

puts "=== ТЕСТ 1: Проверка и отмена своего заказа ==="
prompt1 = "Проверь статус заказа 102. Если он обрабатывается, отмени его."
puts "\nИтоговый ответ Агента:\n#{agent.call(prompt1)}"

puts "\n" + "="*50 + "\n"

puts "=== ТЕСТ 2: Попытка доступа к ЧУЖОМУ заказу #999 ==="
prompt2 = "Отмени заказ #999"
puts "\nИтоговый ответ Агента:\n#{agent.call(prompt2)}"