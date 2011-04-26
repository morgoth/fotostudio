# encoding: UTF-8

Bundler.require
require ::File.expand_path('../lib/google_analytics', __FILE__)

use Rack::Flash
use Rack::GoogleAnalytics, "UA-7563082-4"

configure do
  set :app_file, __FILE__
  set :haml, {:format => :html5}
  set :sessions, true

  Compass.configuration do |config|
    config.project_path = Sinatra::Application.root
    config.sass_dir     = File.join('views', 'stylesheets')
    config.images_dir = File.join('public', 'images')
    config.http_images_path = "/images"
    config.http_path = "/"
    config.http_stylesheets_path = "/stylesheets"
  end

  Mail.defaults do
    delivery_method :smtp, {
      :address        => "smtp.sendgrid.net",
      :port           => 25,
      :user_name      => ENV['SENDGRID_USERNAME'],
      :password       => ENV['SENDGRID_PASSWORD'],
      :domain         => ENV['SENDGRID_DOMAIN'],
      :authentication => :plain
    }
  end
end

helpers do
  def valid?(attributes = {})
    attributes.values.all? { |p| !p.blank? } and email_valid?(attributes['email'])
  end

  def email_valid?(email)
    email_name_regex  = '[A-Z0-9_\.%\+\-]+'
    domain_head_regex = '(?:[A-Z0-9\-]+\.)+'
    domain_tld_regex  = '(?:[A-Z]{2,4}|museum|travel)'
    email =~ /^#{email_name_regex}@#{domain_head_regex}#{domain_tld_regex}$/i
  end
end

before do
  @flash = flash[:notice]
end

get "/stylesheets/screen.css" do
  content_type 'text/css'

  sass :"stylesheets/screen", Compass.sass_engine_options
end

get '/' do
  haml :home
end

get '/kontakt/?' do
  haml :contact
end

get '/informacje/?' do
  haml :info
end

get '/cennik/?' do
  haml :pricing
end

get '/galeria/?' do
  @galleries = Picasa.albums(:google_user => 'kasiafrychel.foto')
  haml :gallery
end

post '/send' do
  if valid?(params)
    email = params["email"]
    body = erb(:email)
    body.force_encoding("UTF-8") if body.respond_to?(:force_encoding)
    Mail.deliver do
      from email
      to "stronka@kasiafrychel.pl"
      subject "Wiadomość ze strony"
      body body
    end
    flash[:notice] = 'Wiadomość została wysłana'
    redirect '/'
  else
    @errors = "Wprowadzone dane nie są poprawne"
    haml :contact
  end
end
