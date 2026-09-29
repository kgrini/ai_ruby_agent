# app/services/ai/tools/order_canceller.rb
require_relative 'base_tool'

module Ai
  module Tools
    class OrderCanceller < BaseTool
      def perform
        order_id = params[:order_id]
        order = find_user_order(order_id)

        unless order
          return { error: "Отказано в доступе или заказ ##{order_id} не существует." }.to_json
        end

        unless order.cancellable?
          return { error: "Заказ ##{order_id} со статусом '#{order.status}' нельзя отменить." }.to_json
        end

        if order.cancel!
          { success: true, message: "Заказ ##{order_id} успешно отменён." }.to_json
        else
          { error: "Ошибка при отмене заказа." }.to_json
        end
      end
    end
  end
end