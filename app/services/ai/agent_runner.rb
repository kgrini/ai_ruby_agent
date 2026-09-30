# app/services/ai/agent_runner.rb
require 'net/http'
require 'json'
require 'uri'
require_relative 'tool_registry'

module Ai
  class AgentRunner
    MAX_STEPS = 5

    def initialize(conversation:, api_key: ENV['OPENAI_API_KEY'])
      @conversation = conversation
      @current_user = conversation.user
      @api_key = api_key
      @uri = URI('https://api.openai.com/v1/chat/completions')
    end

    # Executes the ReAct loop maintaining full conversation history
    def call(user_prompt)
      # Save incoming user input into conversation memory
      conversation.add_message(role: 'user', content: user_prompt)

      step = 0

      loop do
        step += 1
        return "Limit of maximum step iterations reached." if step > MAX_STEPS

        # Build full payload with system context and history
        payload_messages = build_payload_messages
        response = request_llm(payload_messages)

        assistant_message = response.dig("choices", 0, "message")
        finish_reason = response.dig("choices", 0, "finish_reason")

        if finish_reason == "tool_calls"
          process_tools(assistant_message["tool_calls"])
        elsif finish_reason == "stop"
          # Persist final assistant output in conversation state
          final_content = assistant_message["content"]
          conversation.add_message(role: 'assistant', content: final_content)
          return final_content
        end
      end
    end

    private

    attr_reader :conversation, :current_user, :api_key, :uri

    # Constructs array of messages including system prompt and persistent history
    def build_payload_messages
      system_prompt = {
        role: "system",
        content: "You are a customer support assistant. Client name: #{current_user.name}."
      }

      [system_prompt] + conversation.history_for_llm
    end

    # Processes function execution requested by the LLM
    def process_tools(tool_calls)
      tool_calls.each do |tool_call|
        call_id = tool_call["id"]
        fn_name = tool_call.dig("function", "name")
        raw_args = tool_call.dig("function", "arguments")

        params = JSON.parse(raw_args, symbolize_names: true) rescue {}

        result = ToolRegistry.execute(
          name: fn_name,
          current_user: current_user,
          params: params
        )

        # Save tool response into history with corresponding tool_call_id
        conversation.add_message(
          role: 'tool',
          content: result,
          tool_call_id: call_id
        )
      end
    end

    # Performs HTTP POST payload delivery to OpenAI completion endpoint
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