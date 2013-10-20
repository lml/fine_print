FinePrint::Engine.routes.draw do
  resources :agreements do
    get :new_version, on: :member
    put :publish, on: :member
    put :unpublish, on: :member
  end
  resources :user_agreements, :only => [:index, :destroy]
  root :to => 'home#index'
end
