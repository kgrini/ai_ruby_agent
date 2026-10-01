# app/services/ai/execution_logger.rb
module Ai
  # Handles structured console output for agent execution steps (ReAct trace).
  class ExecutionLogger
    COLOR_CODES = {
      reset: "\e[0m",
      cyan: "\e[36m",
      yellow: "\e[33m",
      green: "\e[32m",
      red: "\e[31m",
      bold: "\e[1m"
    }.freeze

    # Logs the start of a new ReAct loop iteration step
    def self.log_step(step_number)
      puts "\n#{colorize("--- [ReAct Step #{step_number}] ---", :cyan)}"
    end

    # Logs the thinking process / raw assistant textual output
    def self.log_thought(thought_content)
      return if thought_content.nil? || thought_content.strip.empty?

      puts "#{colorize("[Thought]", :yellow)} #{thought_content}"
    end

    # Logs tool invocation request initiated by the LLM
    def self.log_action(tool_name, params)
      puts "#{colorize("[Action]", :bold)} Invoking tool '#{tool_name}' with parameters: #{params.to_json}"
    end

    # Logs the result returned from Ruby tool execution
    def self.log_observation(result_json)
      puts "  └─ #{colorize("[Observation]", :green)} #{result_json}"
    end

    # Logs execution limit reached or system errors
    def self.log_error(error_message)
      puts "#{colorize("[Error]", :red)} #{error_message}"
    end

    def self.colorize(text, color_symbol)
      code = COLOR_CODES[color_symbol] || COLOR_CODES[:reset]
      "#{code}#{text}#{COLOR_CODES[:reset]}"
    end

    private_class_method :colorize
  end
end