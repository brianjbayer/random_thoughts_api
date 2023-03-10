Rails.application.routes.draw do
  post '/login', to: 'authentication#login', defaults: { format: 'json' }
  get  '/logout', to: 'authentication#logout', defaults: { format: 'json' }

  resources :random_thoughts, defaults: { format: 'json' }
  resources :users, defaults: { format: 'json' }, only: %i[index show create update destroy]

  mount Rswag::Api::Engine => '/api-docs'
  mount Rswag::Ui::Engine => '/api-docs'
end
