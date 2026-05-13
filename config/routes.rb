Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "auth/login", to: "auth#login"
      delete "auth/logout", to: "auth#logout"

      get "menu_items/search", to: "menu_items#search"

      resources :menus do
        resources :menu_items, shallow: true do
          collection do
            get :search
          end
        end
      end


      resources :orders, only: [ :index, :create, :show, :update ]
    end
  end
end
