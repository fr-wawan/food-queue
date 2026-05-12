Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "auth/login", to: "auth#login"
      delete "auth/logout", to: "auth#logout"

      resources :menus do
        resources :menu_items, shallow: true
      end

      resources :orders, only: [ :index, :create, :show, :update ]
    end
  end
end
