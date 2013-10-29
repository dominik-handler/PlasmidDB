LabLife::Application.routes.draw do
  devise_for :authors

  resources :plasmids
end

