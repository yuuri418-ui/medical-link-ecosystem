class ApplicationController < ActionController::Base
  # Deviseの機能が使われる前に、カスタムパラメータを許可するメソッドを実行する
  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def configure_permitted_parameters
    # 新規登録（sign_up）の際に、追加したカラムの保存を許可する
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :last_name, :first_name, :last_name_kana, :first_name_kana, 
      :gender, :birthday, :phone_number, :diagnosis_name, :started_at
    ])
    
    # アカウント更新（account_update）の際も同様に許可する
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :last_name, :first_name, :last_name_kana, :first_name_kana, 
      :gender, :birthday, :phone_number, :diagnosis_name, :started_at
    ])
  end
end
