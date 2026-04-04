class MedicationLog < ApplicationRecord
  belongs_to :daily_log

  validates :medicine_name, presence: true

  require 'net/http'
  require 'uri'
  require 'json'

  # AIに一般名を問い合わせるメソッド
  def fetch_generic_name_en
    return if name.blank?

    # 成功した「URL」と「モデル」を使います
    api_key = ENV['GEMINI_API_KEY']
    uri = URI.parse("https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite-preview:generateContent?key=#{api_key}")

    payload = {
      contents: [{
        parts: [{ text: "薬剤名「#{name}」の英語の一般名を1つだけ答えて。解説は不要。" }]
      }]
    }.to_json

    begin
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri, { 'Content-Type' => 'application/json' })
      request.body = payload
      
      response = http.request(request)
      
      if response.code == "200"
        result = JSON.parse(response.body)
        # AIの回答（Loxoprofenなど）を抽出
        result['candidates'][0]['content']['parts'][0]['text'].strip
      else
        "Translation Error"
      end
    rescue => e
      "Connection Error: #{e.message}"
    end
  end
end
