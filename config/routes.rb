LabLife::Application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
  devise_for :authors
  root :to => "plasmids#index"

  resources :plasmids
  get 'filter_plasmid_index' => "plasmids#filter_index", :as => :filter_plasmid_index

end

