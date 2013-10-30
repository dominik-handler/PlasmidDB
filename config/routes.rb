LabLife::Application.routes.draw do
  devise_for :authors
  root :to => "plasmids#index"

  resources :plasmids
  get 'filter_plasmid_index' => "plasmids#filter_index", :as => :filter_plasmid_index

end

