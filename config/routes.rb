Rails.application.routes.draw do
  get "words/create"
    root "rooms#index"

    resources :rooms, only: %i[index new create show edit update destroy]
    resources :words, only: [:create]
  end
