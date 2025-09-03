Rails.application.routes.draw do
  devise_for :users

  #認証済みか、認証済みでないかで2種類のrootのどちらかを出す
  authenticated :user do  #認証済みのユーザー
    root to: 'rooms#index', as: :authenticated_root
  end

  unauthenticated do  #認証済みでないユーザー
    devise_scope :user do
      root to: 'devise/sessions#new', as: :unauthenticated_root
    end
  end

  resources :rooms, only: %i[index show create new] do
    get :result, on: :member # この行を追加
    get :new    #ルームの新規作成画面
  end
  resources :words, only: [:create]
end
