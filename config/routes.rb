Rails.application.routes.draw do
  root "dashboards#show"

  get "sign_up", to: "users#new"
  post "sign_up", to: "users#create"
  get "sign_in", to: "sessions#new"
  post "sign_in", to: "sessions#create"
  delete "sign_out", to: "sessions#destroy"
  resource :demo, only: %i[create destroy]

  get "join", to: "memberships#new"
  post "join", to: "memberships#create"

  resources :residents, only: %i[show new create edit update] do
    resources :memberships, only: %i[index destroy]
    resources :signal_items, only: %i[new create edit update destroy]
    resources :visits, only: %i[index show new create]
    resource :brief, only: :show

    resources :care_concerns, only: %i[index show new create] do
      resources :staff_responses, only: :create
      resource :recheck_assignment, only: :update
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
