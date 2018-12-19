# README

Esempio di client oauth2 realizzato con gem 'omniauth-oauth2'.


Il server gira su http://localhost:3000
prima di tutto occorre configurare l'applicazione client sul server:
http://localhost:3000/oauth/applications/new
fornendo nome dell'applicazione = oauth-client
e redirect-uri = http://localhost:3001/auth/doorkeeper/callback
confermando vengono fornite le chiavi Application UID e Secret
che devono essere impostate sul client in config/initializers/omniauth.rb

Il Flusso quando si visita la home del client (http://localhost:3001):
1) si viene rediretti su http://localhost:3001/auth/doorkeeper definito in routes.rb
   questo url fa partire l'autenticazione oauth utilizzando “doorkeeper” omniauth strategy
2) si viene sempre reindirizzati al server provider SSO definito nel client in lib/doorkeeper.rb
3) se non si e' autenticati al server si viene reindirizzati su server a localhost:3000/users/sign_in
4) dopo aver effettuato l'accesso si viene indirizzati sul client a /auth/doorkeeper/callback che
   corrisponde in routes a controller application metodo authentication_callback
5) in questo esempio vengono stampate in json le informazioni ricevute dal server

# Implementazione Client SSO

* rails new oauth-client

cd oauth-client

* GemFile
...
gem 'omniauth-oauth2'
...
* bundle install

* create lib/doorkeeper.rb
...
code

require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Doorkeeper < OmniAuth::Strategies::OAuth2
      option :name, 'doorkeeper'
      option :client_options, {
        site:          'http://localhost:3000',
        authorize_url: 'http://localhost:3000/oauth/authorize'
      }

      uid {
        raw_info['id']
      }

      info do
        {
          email: raw_info['email'],
        }
      end

      extra do
        { raw_info: raw_info }
      end

      def raw_info
        @raw_info ||= access_token.get('/me').parsed
      end
    end
  end
end
...
* touch config/initializers/omniauth.rb
...
require 'doorkeeper'

Rails.application.config.middleware.use OmniAuth::Builder do
  #provider :doorkeeper, <application_id>, <application_secret>
  provider :doorkeeper, '0f6e92286277c968bcfafbba99c705ad0cba824841c4452b3442da351f4c89ba', 'f8d66b638527d771e774d62d73d888a6809a5badf83fda17ad7f0e885a5aa5f3'
end
...
* config/routes.rb:
...
Rails.application.routes.draw do
  root to: redirect('/auth/doorkeeper')

  get '/auth/:provider/callback' => 'application#authentication_callback'
end
...
* application_controller.rb:
...
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def authentication_callback
    auth = request.env['omniauth.auth']
    render json: auth.to_json
  end
end

* rails db:create
