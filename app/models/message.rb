# app/models/message.rb
class Message
  attr_reader :id, :conversation_id, :role, :content, :tool_call_id, :created_at

  # Valid roles: 'user', 'assistant', 'system', 'tool'
  def initialize(id:, conversation_id:, role:, content:, tool_call_id: nil)
    @id = id
    @conversation_id = conversation_id
    @role = role
    @content = content
    @tool_call_id = tool_call_id
    @created_at = Time.now
  end

  # Converts the internal message object to OpenAI API message payload format
  def to_h
    payload = { role: role, content: content }
    payload[:tool_call_id] = tool_call_id if tool_call_id
    payload
  end
end