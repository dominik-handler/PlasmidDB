LabLife::Application.routes.draw do
  devise_for :authors
  root :to => "plasmids#index"

  resources :plasmids
end

