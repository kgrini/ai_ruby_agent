# app/services/ai/agent_runner.rb
require 'net/http'
require 'json'
require 'uri'
require_relative 'tool_registry'

module Ai
  class AgentRunner
    MAX_STEPS = 5

    def initialize(current_user:, api_key: ENV['OPENAI_API_KEY'])
      @current_user = current_user
      @api_key = api_key
      @uri = URI('https://api.openai.com/v1/chat/completions')
    end

    def call(user_prompt)
      messages = [
        {
          role: "system",
          content: "Ты — ассистент поддержки. Клиент: #{current_user.name}. Используй доступные инструменты для решения задач."
        },
        { role: "user", content: user_prompt }
      ]

      step = 0

      loop do
        step += 1
        return "Превышен лимит итераций цикла." if step > MAX_STEPS

        puts "\n[Итерация #{step}] Запрос к LLM..."
        response = request_llm(messages)

        assistant_message = response.dig("choices", 0, "message")
        messages << assistant_message

        finish_reason = response.dig("choices", 0, "finish_reason")

        if finish_reason == "tool_calls"
          process_tools(assistant_message["tool_calls"], messages)
        elsif finish_reason == "stop"
          return assistant_message["content"]
        end
      end
    end

    private

    attr_reader :current_user, :api_key, :uri

    def process_tools(tool_calls, messages)
      tool_calls.each do |tool_call|
        call_id = tool_call["id"]
        fn_name = tool_call.dig("function", "name")
        raw_args = tool_call.dig("function", "arguments")

        params = JSON.parse(raw_args, symbolize_names: true) rescue {}

        puts "🤖 AI вызывает инструмент: #{fn_name}(#{params})"

        result = ToolRegistry.execute(
          name: fn_name,
          current_user: current_user,
          params: params
        )

        puts "  └─ Результат инструмента: #{result}"

        messages << {
          role: "tool",
          tool_call_id: call_id,
          content: result
        }
      end
    end

    def request_llm(messages)
      req = Net::HTTP::Post.new(uri, {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{api_key}"
      })

      req.body = {
        model: "gpt-4o-mini",
        messages: messages,
        tools: ToolRegistry.schemas,
        temperature: 0.1
      }.to_json

      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(req)
      end

      JSON.parse(res.body)
    end
  end
end