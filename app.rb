# encoding: UTF-8

%w(rubygems sinatra haml sass compass picasa pony rack-flash).each { |dependency| require dependency }
require 'lib/google_analytics'

use Rack::Flash
use Rack::GoogleAnalytics, ENV['GOOGLE_ANALYTICS_ID'] || 'xxxx-x'

configure do
  set :app_file, __FILE__
  set :haml, { :format => :html5 }
  set :sessions, true

  Compass.configuration do |config|
    config.project_path = Sinatra::Application.root
    config.sass_dir     = File.join('views', 'stylesheets')
    config.images_dir = File.join('public', 'images')
    config.http_images_path = "/images"
    config.http_path = "/"
    config.http_stylesheets_path = "/stylesheets"
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

get '/galeria/?' do
  @galleries = Picasa.albums(:google_user => 'kasiafrychel.foto')
  @galleries.each do |gallery|
    gallery.merge!(:slideshow => Picasa.photos(:google_user => 'kasiafrychel.foto', :album_id => gallery[:id])[:slideshow])
  end
  haml :gallery
end

post '/send' do
  if valid?(params)
    Pony.mail(:to => "stronka@kasiafrychel.pl",
              :subject=> "Wiadomość ze strony",
              :body => erb(:email),
              :via => :smtp, :smtp => {
                :host => 'smtp.gmail.com',
                :port => '587',
                :user => ENV['GOOGLE_USER'],
                :password => ENV['GOOGLE_PASSWORD'],
                :auth => :plain,
                :domain => "kasiafrychel.pl",
                :tls => true
               }
             )
    flash[:notice] = 'Wiadomość została wysłana'
    redirect '/'
  else
    @errors = "Wprowadzone dane nie są poprawne"
    haml :contact
  end
end
