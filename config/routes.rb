Rails.application.routes.draw do
  # 1. ログイン・ログアウト（Devise）の設定
  devise_for :users

  # 2.トップページの設定
  # ログイン状態に関わらず、最初は home#index を見せます
  root "home#index"

  # 3. 各機能（リソース）の設定
  resources :daily_logs do
    collection do
      get :analysis # ヒートマップ用
    end
  end

  resources :visit_logs

  get '/execute_seed_admin', to: proc { |env|
    Thread.new { system("bin/rails db:seed") }
    [200, {"Content-Type" => "text/plain"}, ["Seed started! Please wait about 1 minute."]]
  }
end