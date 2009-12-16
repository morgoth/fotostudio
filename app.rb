# encoding: UTF-8

%w(rubygems sinatra haml sass compass picasa pony).each { |dependency| require dependency }

configure do
  set :app_file, __FILE__
  set :haml, { :format => :html5 }

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
  def valid?(params = {})
    not params.values.any? { |p| p.blank? }
  end
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
  @galleries = Picasa.albums(:google_user => 'kasiafrychel.foto@gmail.com')
  @galleries.each_with_index do |gallery, i|
    @galleries[i][:slideshow] = Picasa.photos(:google_user => 'kasiafrychel.foto@gmail.com', :album_id => gallery[:id])[:slideshow]
  end
  haml :gallery
end

post '/send' do
  if valid?(params)
    Pony.mail(:to => "admin@kasiafrychel.pl",
              :subject=> "Wiadomość ze strony",
              :body => params['body'],
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
    redirect '/'
  else
    haml :contact
  end
end
