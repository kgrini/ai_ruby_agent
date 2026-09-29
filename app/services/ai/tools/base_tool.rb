# app/services/ai/tools/base_tool.rb
module Ai
  module Tools
    class BaseTool
      attr_reader :current_user, :params

      def initialize(current_user:, params:)
        @current_user = current_user
        @params = params
      end

      def perform
        raise NotImplementedError, "#{self.class.name} должен реализовать метод #perform"
      end

      protected

      # Ищем заказ только у текущего пользователя!
      def find_user_order(order_id)
        current_user.find_order(order_id)
      end
    end
  end
end