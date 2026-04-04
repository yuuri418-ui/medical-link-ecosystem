# spec/requests/visit_logs_spec.rb
require 'rails_helper'

RSpec.describe "VisitLogs", type: :request do
  let!(:user) { create(:user) }

  before do
    # デフォルトのホストを 127.0.0.1 に固定
    host! "127.0.0.1"
  end

  describe "GET /visit_logs" do
    it "ログインしている場合、正常にレスポンスを返すこと" do
      sign_in user
      get visit_logs_path
      expect(response).to have_http_status(:success)
    end

    it "ログインしていない場合、ログイン画面にリダイレクトされること" do
      get visit_logs_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end