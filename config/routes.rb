Rails.application.routes.draw do
  resource :games, only: [:create, :show] do
    post :check
    put :pause
    put :resume
  end
end
