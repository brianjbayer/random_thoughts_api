Rails.application.routes.draw do
  resources :random_thoughts, defaults: { format: 'json' }

  mount Rswag::Api::Engine => '/api-docs'
  mount Rswag::Ui::Engine => '/api-docs'
end
