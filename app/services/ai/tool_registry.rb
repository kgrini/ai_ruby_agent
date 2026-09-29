# app/services/ai/tool_registry.rb
require_relative 'tools/order_status'
require_relative 'tools/order_canceller'

module Ai
  class ToolRegistry
    MAPPING = {
      "get_order_status" => Ai::Tools::OrderStatus,
      "cancel_order"     => Ai::Tools::OrderCanceller
    }.freeze

    SCHEMAS = [
      {
        type: "function",
        function: {
          name: "get_order_status",
          description: "Возвращает текущий статус заказа текущего пользователя",
          parameters: {
            type: "object",
            properties: {
              order_id: { type: "integer", description: "ID заказа" }
            },
            required: ["order_id"]
          }
        }
      },
      {
        type: "function",
        function: {
          name: "cancel_order",
          description: "Отменяет заказ текущего пользователя, если он в статусе processing",
          parameters: {
            type: "object",
            properties: {
              order_id: { type: "integer", description: "ID заказа" }
            },
            required: ["order_id"]
          }
        }
      }
    ].freeze

    def self.schemas
      SCHEMAS
    end

    def self.execute(name:, current_user:, params:)
      tool_class = MAPPING[name]

      unless tool_class
        return { error: "Инструмент '#{name}' недоступен." }.to_json
      end

      tool_class.new(current_user: current_user, params: params).perform
    end
  end
end