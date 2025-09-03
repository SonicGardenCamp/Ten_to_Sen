Rails.application.routes.draw do
  devise_for :users

  # 認証済みユーザーのルートパス
  authenticated :user do
    root to: 'rooms#index', as: :authenticated_root
  end

  devise_scope :user do
    unauthenticated do
      root to: 'devise/sessions#new', as: :unauthenticated_root
    end
  end
  
  resources :rooms, only: %i[index show create new] do
    get :result, on: :member
  end
  
  resources :words, only: [:create]
end