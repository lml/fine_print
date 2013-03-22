FinePrint::Engine.routes.draw do
  resources :agreements do
    get :new_version
  end
  resources :user_agreements, :only => [:index, :create, :destroy]
  root :to => 'home#index'
end
