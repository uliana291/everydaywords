Rails.application.routes.draw do

  root 'welcome#index'

  devise_for :users, controllers: { omniauth_callbacks: "omniauth_callbacks" }


  resources :benchmarks, only: :none do
    collection do
      get :simple
    end
  end

  scope '/api' do
    get '/context_text/list', to: 'context_text#list'
    get '/context_text/list/user', to: 'context_text#list_user'
    get '/context_text/list_by_url', to: 'context_text#url_list'
    resources :context_text, only: [ :create, :show, :update, :destroy]

    scope '/user' do
      get '/list', to: 'user#list'
      get '/switch/:id', to: 'user#become'
      get '/profile/', to: 'user#show'
      get '/:id/profile', to: 'user#show'
      match '/profile', to: 'user#update', via: :patch
      match '/restore_session', to: 'user#restore_session', via: :post
      get '/current', to: 'user#current'
    end

    scope '/trainings' do
      match '/daily', to: 'trainings#add_daily', via: :post
      get '/daily/list', to: 'trainings#list'
      get '/daily/:id', to: 'trainings#get'
      match '/daily/:id', to: 'trainings#destroy', via: :delete
      get '/daily/:id/finish', to: 'trainings#finish_daily'
      get '/:id/finish', to: 'trainings#finish_qa'
      match '/daily/:id', to: 'trainings#update', via: :patch
      match '/:id', to: 'trainings#update', via: :patch

      scope '/qa' do
        get '/:group_name/list', to: 'trainings#list'
        get '/:group_name/:id', to: 'trainings#get'
        match '/:group_name', to: 'trainings#add_qa', via: :post
      end
    end

    scope '/qa_groups' do
      get 'list', to: 'qa_groups#list'
    end

    get '/language/list', to: 'language#list'
    resources :language, only: [ :show, :create, :destroy, :update]

    get '/translation/list/user', to: 'translation#list_user'
    match '/translation/:id', to: 'translation#destroy', via: :delete
    match '/add_translation', to: 'translation#add', via: :post

    get '/ping', to: 'api#ping'
    match '/proxy_request', to: 'api#proxy_request', via: :post

  end

  get '/login' => 'welcome#index'
  get '/translations/*other' => 'welcome#index'
  get '/context_texts/*other' => 'welcome#index'
  get '/trainings/*other' => 'welcome#index'
  get '/user/*other' => 'welcome#index'

  get '/404' => 'errors#not_found'
  get '/500' => 'errors#exception'

end
