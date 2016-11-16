Rails.application.routes.draw do
  resources :boards
  
  post 'boards/:id/drop_token' => 'boards#drop_token'

end
