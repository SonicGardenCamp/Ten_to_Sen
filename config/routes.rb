Rails.application.routes.draw do
  devise_for :users
  root 'rooms#index'

  resources :rooms, only: %i[index show create] do
    get :result, on: :member # この行を追加
  end
  resources :words, only: [:create]
end
