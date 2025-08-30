Rails.application.routes.draw do
  root "rooms#index"

  resources :rooms, only: %i[index create show]
  resources :words, only: [:create]
end