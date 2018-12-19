Rails.application.routes.draw do
  root to: redirect('/auth/doorkeeper')

  get '/auth/:provider/callback' => 'application#authentication_callback'
end
