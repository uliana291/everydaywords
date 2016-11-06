Rails.application.routes.draw do

  root 'welcome#index'

  devise_for :users, controllers: { omniauth_callbacks: "omniauth_callbacks" }


  resources :benchmarks, only: :none do
    collection do
      get :simple
    end
  end

  scope '/api' do
    get '/language/list', to: 'language#list'
    resources :language, only: [ :show, :create, :destroy, :update]
    get '/context_text/list', to: 'context_text#list'
    get '/context_text/list/user', to: 'context_text#list_user'
    get '/context_text/list_by_url', to: 'context_text#url_list'
    get '/translation/list/user', to: 'translation#list_user'
    match '/translation/:id', to: 'translation#destroy', via: :delete
    get '/trainings/get', to: 'translation#list_translations'
    resources :context_text, only: [ :create, :show, :update, :destroy]
    match '/add_translation', to: 'translation#add', via: :post
    match '/trainings/daily', to: 'trainings#add', via: :post
    get '/trainings/daily/list', to: 'trainings#list'
    get '/trainings/daily/:id', to: 'trainings#get'
    match '/trainings/daily/:id', to: 'trainings#destroy', via: :delete
    get '/trainings/daily/:id/finish', to: 'trainings#finish_daily'
    match '/trainings/daily/:id', to: 'trainings#update', via: :patch
    get '/user/current', to: 'user#current'
    get '/ping', to: 'api#ping'
    get '/user/list', to: 'user#list'
    get '/user/switch/:id', to: 'user#become'
    get '/user/profile/', to: 'user#show'
    get '/user/:id/profile', to: 'user#show'
    match '/user/profile', to: 'user#update', via: :patch
  end

  get '/404' => 'errors#not_found'
  get '/500' => 'errors#exception'

end