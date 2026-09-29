# app/services/ai/tools/order_status.rb
require_relative 'base_tool'

module Ai
  module Tools
    class OrderStatus < BaseTool
      def perform
        order_id = params[:order_id]
        order = find_user_order(order_id)

        unless order
          return { error: "Заказ ##{order_id} не найден в вашем аккаунте." }.to_json
        end

        {
          order_id: order.id,
          status: order.status,
          total_price: "#{order.total_price} USD",
          cancellable: order.cancellable?
        }.to_json
      end
    end
  end
end