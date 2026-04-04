class MedicationLog < ApplicationRecord
  belongs_to :daily_log
  validates :medicine_name, presence: true

  require 'net/http'
  require 'uri'
  require 'json'

  # 保存される直前に、AI翻訳を実行して english_name カラムに保存する
  before_save :set_english_name, if: :medicine_name_changed?

  # CSV出力用のクラスメソッド
  def self.to_csv
    CSV.generate(headers: true) do |csv|
      csv << ["日付", "薬の名前", "英語名(AI)", "服用状況"]
      all.each do |log|
        csv << [
          log.daily_log&.date, 
          log.medicine_name, 
          log.english_name, 
          log.is_taken ? "服用済み" : "未服用"
        ]
      end
    end
  end

  private

  def set_english_name
    api_key = ENV['GEMINI_API_KEY']
    return if api_key.blank?

    uri = URI.parse("https://generativelanguage.googleapis.com/v1beta/models/gemini-3.1-flash-lite-preview:generateContent?key=#{api_key}")
    
    payload = {
      contents: [{
        parts: [{ text: "薬剤名「#{medicine_name}」の英語の一般名を1つだけ答えて。解説は不要。" }]
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
        # 翻訳結果を english_name カラムに代入
        self.english_name = result['candidates'][0]['content']['parts'][0]['text'].strip
      end
    rescue => e
      # エラーが起きても保存自体は失敗させない（ログに残すだけ）
      Rails.logger.error "AI Translation Error: #{e.message}"
    end
  end
end