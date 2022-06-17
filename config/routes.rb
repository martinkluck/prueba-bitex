Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root 'home#index'

  post '/' => 'home#create'
  get '/base_information' => 'home#base_information'
  post '/create_base_information' => 'home#create_base_information'
  get '/domicile' => 'home#domicile'
  post '/create_domicile' => 'home#create_domicile'
  get '/document' => 'home#document'
  post '/create_document' => 'home#create_document'
  get '/result' => 'home#result'
  post '/complete_issue' => 'home#complete_issue'
end
