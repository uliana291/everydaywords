Rails.application.routes.draw do
  resources :benchmarks, only: :none do
    collection do
      get :simple
    end
  end

  get '/api/language/list', to: 'language#list'
  get '/api/language/:id', to: 'language#show'

  match '/api/language', to: 'language#create', via: [:post]

  match '/api/language/:id', to: 'language#delete', via: [:delete]

  match '/api/language/:id', to: 'language#update', via: [:patch]

  get '/404' => 'errors#not_found'
  get '/500' => 'errors#exception'

end