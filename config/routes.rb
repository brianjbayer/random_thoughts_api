Rails.application.routes.draw do
  post '/login', to: 'authentication#login', defaults: { format: 'json' }

  get  '/users/:id', to: 'users#show', as: 'user', defaults: { format: 'json' }
  post '/users', to: 'users#create', defaults: { format: 'json' }

  resources :random_thoughts, defaults: { format: 'json' }

  mount Rswag::Api::Engine => '/api-docs'
  mount Rswag::Ui::Engine => '/api-docs'
end
