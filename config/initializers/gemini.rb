require 'gemini_craft'

GeminiCraft.configure do |config|
  config.api_key = Rails.application.credentials.google[:gemini_api_key]
  config.logger = Rails.logger
end