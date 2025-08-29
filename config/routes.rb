Rails.application.routes.draw do
  # get "words/create" # ◀️ この行は不要なので削除
  root "rooms#index"

  # 必要なアクションだけに絞る
  resources :rooms, only: %i[index create show]
  resources :words, only: [:create]
end