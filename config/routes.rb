FinePrint::Engine.routes.draw do
  resources :contracts do
    get :new_version, on: :member
    put :publish, on: :member
    put :unpublish, on: :member
  end
  resources :signatures, :only => [:index, :destroy]
  root :to => 'home#index'
end
