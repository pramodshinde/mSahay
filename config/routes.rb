Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "tickets#index"
  resources :tickets do
    collection do
      post :search
    end
  end

  post '/launch' => 'tickets#launch'
  get '/launch' => 'tickets#launch'
end
