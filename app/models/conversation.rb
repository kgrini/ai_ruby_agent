# app/models/conversation.rb
require_relative 'message'

class Conversation
  attr_reader :id, :user, :messages

  def initialize(id:, user:)
    @id = id
    @user = user
    @messages = []
  end

  # Appends a new message to the conversation history
  def add_message(role:, content:, tool_call_id: nil)
    message_id = messages.size + 1
    message = Message.new(
      id: message_id,
      conversation_id: id,
      role: role,
      content: content,
      tool_call_id: tool_call_id
    )
    @messages << message
    message
  end

  # Returns messages formatted for OpenAI API execution
  def history_for_llm
    messages.map(&:to_h)
  end
end