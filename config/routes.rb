Rails.application.routes.draw do
  resources :random_thoughts,
            only: %i[index show create update],
            defaults: { format: 'json' }
  mount Rswag::Api::Engine => '/api-docs'
  mount Rswag::Ui::Engine => '/api-docs'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
