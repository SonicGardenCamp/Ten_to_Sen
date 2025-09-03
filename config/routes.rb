Rails.application.routes.draw do
  devise_for :users
  root 'rooms#index'

  resources :rooms, only: %i[index show create new] do
    get :result, on: :member # この行を追加
    get :new    #ルームの新規作成画面
  end
  resources :words, only: [:create]
end
