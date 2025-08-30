Rails.application.routes.draw do
  root "rooms#index"
  resources :rooms, only: %i[index create show] do
    get :result, on: :member
  resources :words, only: [:create]
end