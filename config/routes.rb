Rails.application.routes.draw do
  devise_for :models
  namespace :api do
    namespace :v1 do
      post 'guest_login', to: 'guests#create'
    end
  end
  root "rooms#index"

  resources :rooms, only: %i[index create show] do
    get :result, on: :member # この行を追加
  end
  resources :words, only: [:create]
end
