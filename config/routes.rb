Rails.application.routes.draw do

  root 'welcome#index'

  resources :benchmarks, only: :none do
    collection do
      get :simple
    end
  end

  scope '/api' do
    get '/language/list', to: 'language#list'
    resources :language, only: [ :show, :create, :destroy, :update]
    get '/context_text/list', to: 'context_text#list'
    resources :context_text, only: [ :create, :show, :update, :destroy]
    match '/add_translation', to: 'translation#add', via: :post
  end

  get '/404' => 'errors#not_found'
  get '/500' => 'errors#exception'

end