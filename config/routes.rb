Rails.application.routes.draw do
  root "residents#index"

  resources :residents, only: %i[index show new create] do
    resources :signal_items, only: %i[new create edit update destroy]

    resources :care_concerns, only: %i[index show new create] do
      resources :staff_responses, only: :create
      resources :rechecks, only: :create
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
