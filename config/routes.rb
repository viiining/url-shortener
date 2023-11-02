Rails.application.routes.draw do
  root "urls#new"
  resources :urls, only: [:create, :show, :new]
  get '/shorts/:short_url', to: 'shorts#show', as: 'short'
end
