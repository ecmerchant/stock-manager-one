require 'resque/server'

Rails.application.routes.draw do

  get 'items' => 'items#show'
  get 'items/show'

  get 'items/search'

  root to: 'apps#show'
  get 'apps/show'
  post 'stocks/delete'
  get 'stocks/show'
  post 'stocks/show'
  post 'stocks/update'
  get 'stocks/search'
  post 'stocks/search'
  post 'stocks/import'
  get 'stocks/export'
  post 'stocks/export'
  post 'stocks/load'
  post 'stocks/setpw'
  get 'stocks/export.csv'  => 'stocks#show'

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  mount Resque::Server.new, at: "/resque"

  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
