Rails.application.routes.draw do
  devise_for :users

  devise_scope :user do
    # 未ログイン時の root はログイン画面
    root to: 'devise/sessions#new'
  end

  resources :rooms, only: %i[index show create new] do
    get :result, on: :member # この行を追加
    get :new    #ルームの新規作成画面
  end
  resources :words, only: [:create]
end
