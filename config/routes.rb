Rails.application.routes.draw do

  root 'welcome#index'

  devise_for :users, controllers: { omniauth_callbacks: "omniauth_callbacks" }


  resources :benchmarks, only: :none do
    collection do
      get :simple
    end
  end

  scope '/api' do

    scope '/user' do
      get '/list', to: 'user#list'
      get '/switch/:id', to: 'user#become'
      get '/profile/', to: 'user#show'
      get '/:id/profile', to: 'user#show'
      match '/profile', to: 'user#update', via: :patch
      get '/current', to: 'user#current'
    end

    resources :context_text, only: [ :create, :show, :update, :destroy]
    scope '/context_text' do
      get '/list', to: 'context_text#list'
      get '/list/user', to: 'context_text#list_user'
      get '/list_by_url', to: 'context_text#url_list'
    end

    scope '/trainings' do
      match '/daily', to: 'trainings#add', via: :post
      get '/daily/list', to: 'trainings#list'
      get '/daily/:id', to: 'trainings#get'
      match '/daily/:id', to: 'trainings#destroy', via: :delete
      get '/daily/:id/finish', to: 'trainings#finish_daily'
      match '/daily/:id', to: 'trainings#update', via: :patch
      get '/get', to: 'translation#list_translations'
    end

    get '/language/list', to: 'language#list'
    resources :language, only: [ :show, :create, :destroy, :update]

    get '/translation/list/user', to: 'translation#list_user'
    match '/translation/:id', to: 'translation#destroy', via: :delete
    match '/add_translation', to: 'translation#add', via: :post

    get '/ping', to: 'api#ping'
  end

  get '/login' => 'welcome#index'
  get '/translations/*other' => 'welcome#index'
  get '/context_texts/*other' => 'welcome#index'
  get '/trainings/*other' => 'welcome#index'
  get '/user/*other' => 'welcome#index'

  get '/404' => 'errors#not_found'
  get '/500' => 'errors#exception'

end