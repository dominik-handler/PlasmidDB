LabLife::Application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
  devise_for :authors
  root :to => "plasmids#index"

  resources :plasmids do
    get 'remove_image' => 'plasmids#remove_image', :as => :remove_image
    get 'remove_attachment' => 'plasmids#remove_attachment', :as => :remove_attachment
  end

  get 'filter_plasmid_index' => "plasmids#filter_index", :as => :filter_plasmid_index

end

