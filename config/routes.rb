FinePrint::Engine.routes.draw do
  resources :agreements
  resources :user_agreements, :only => [:index, :create, :destroy]
end
