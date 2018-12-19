require 'doorkeeper'

Rails.application.config.middleware.use OmniAuth::Builder do
#  provider :doorkeeper, <application_id>, <application_secret>
  provider :doorkeeper, '0f6e92286277c968bcfafbba99c705ad0cba824841c4452b3442da351f4c89ba', 'f8d66b638527d771e774d62d73d888a6809a5badf83fda17ad7f0e885a5aa5f3', {:provider_ignores_state => true}
end
