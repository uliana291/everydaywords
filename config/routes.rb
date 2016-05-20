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
    resources :context_text, only: [ :create, :show, :update, :destroy]
    match '/add_translation', to: 'translation#add', via: :post
    get '/user/current', to: 'user_api#current'
  end

  get '/404' => 'errors#not_found'
  get '/500' => 'errors#exception'

end