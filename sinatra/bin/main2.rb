require 'rubygems'
require 'bundler/setup'
require 'sinatra'

#require 'json'
#require 'rack'

#require 'proxy/settings'
#require 'proxy/settings/plugin'

#require 'proxy/plugins'
#require 'proxy/plugin'
#require 'proxy/plugin_initializer'




module Proxy
  SETTINGS = Settings.load_global_settings
  VERSION = 0

#require 'puppetca/puppetca'
#require 'puppet_proxy/puppet'
#require 'puppet_proxy_customrun/puppet_proxy_customrun'
#require 'puppet_proxy_legacy/puppet_proxy_legacy'
#require 'puppet_proxy_mcollective/puppet_proxy_mcollective'
#require 'puppet_proxy_puppet_api/puppet_proxy_puppet_api'
#require 'puppet_proxy_puppetrun/puppet_proxy_puppetrun'
#require 'puppet_proxy_salt/puppet_proxy_salt'
#require 'puppet_proxy_ssh/puppet_proxy_ssh'


#$LOAD_PATH.unshift(*Dir[File.expand_path("../../lib", __FILE__), File.expand_path("../../modules", __FILE__)])


  def self.version
    {:version => VERSION}
  end
end









get '/' do
  'Hello world!'
end

 get "/features" do
    begin
        '[]'
    rescue => e
      log_halt 400, e
    end
  end

  get "/version" do
    begin

     '{"version":"1.14.0-develop","modules":{}}'

      #{:version => Proxy::VERSION, :modules => modules}.to_json
   rescue => e
            log_halt 400, e
                end
                end

