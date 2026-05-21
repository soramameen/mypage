Rails.application.routes.draw do
  get "pages/home"
  root "pages#home"

  resources :blogs, only: [ :index, :show ]
  get "blogs/index", to: "blogs#index", as: :blogs_index

  namespace :admin do
    root to: redirect("/admin/blogs")
    resources :blogs
  end

  post "likes/increment", to: "likes#create"
  get "likes/:page_identifier", to: "likes#show"

  # Chat routes
  namespace :chat, path: "chat" do
    get "set_name", to: "sessions#new"
    post "set_name", to: "sessions#create"
    resources :rooms, only: [ :index, :show, :create ] do
      resources :messages, only: [ :create ] do
        resources :reactions, only: [ :create, :destroy ]
      end
    end
    resources :messages, only: [ :edit, :update, :destroy ]
  end
  get "/chat", to: "chat/rooms#index", as: :chat

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
