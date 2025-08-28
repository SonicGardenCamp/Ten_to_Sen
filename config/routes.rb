Rails.application.routes.draw do
    root "rooms#index"

    resources :rooms, only: %i[index new create show edit update destroy]
end
