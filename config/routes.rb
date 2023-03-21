Rails.application.routes.draw do
  root to: 'documentation#show'

  concern :base_api do
    post '/login', to: 'authentication#login', defaults: { format: 'json' }
    delete '/login', to: 'authentication#logout', as: 'logout', defaults: { format: 'json' }

    resources :random_thoughts, defaults: { format: 'json' }
    resources :users, defaults: { format: 'json' }, only: %i[index show create update destroy]
  end

  namespace :v1 do
    concerns :base_api
  end

  mount Rswag::Api::Engine => '/api-docs'
  mount Rswag::Ui::Engine => '/api-docs'
end
