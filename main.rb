# main.rb
require_relative 'app/models/order'
require_relative 'app/models/user'
require_relative 'app/models/conversation'
require_relative 'app/services/ai/agent_runner'

# Seed domain data
order1 = Order.new(id: 101, user_id: 1, status: "shipped", total_price: 150)
order2 = Order.new(id: 102, user_id: 1, status: "processing", total_price: 80)
user = User.new(id: 1, name: "Ivan", orders: [order1, order2])

# Initialize persistent conversation session for user
conversation = Conversation.new(id: 1001, user: user)
agent = Ai::AgentRunner.new(conversation: conversation)

puts "=== Step 1: Querying order status ==="
puts agent.call("What is the status of my order #102?")

puts "\n=== Step 2: Contextual action request without repeating order ID ==="
# Notice we don't mention order #102 explicitly! The agent remembers it from session history.
puts agent.call("Please cancel it.")