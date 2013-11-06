FinePrint::Engine.routes.draw do
  resources :contracts do
    member do
      get :new_version
      put :publish
      put :unpublish
    end
  end

  resources :signatures, :only => [:index, :destroy]

  root :to => 'home#index'
end
