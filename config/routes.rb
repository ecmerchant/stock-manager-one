require 'resque/server'

Rails.application.routes.draw do

  root to: 'apps#show'
  get 'apps/show'

  get 'stocks/show'
  post 'stocks/import'
  post 'stocks/export'
  post 'stocks/load'


  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  mount Resque::Server.new, at: "/resque"

  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
