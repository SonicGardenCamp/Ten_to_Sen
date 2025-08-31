Rails.application.routes.draw do
  get "words/create"
  root "rooms#index"

  resources :rooms, only: %i[index create show] do
    get :result, on: :member # この行を追加
  end
  resources :words, only: [:create]
end