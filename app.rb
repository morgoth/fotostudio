%w(rubygems sinatra haml sass compass picasa).each { |dependency| require dependency }

configure do
  set :haml, { :format => :html5 }
  set :app_file, __FILE__

  Compass.configuration do |config|
    config.project_path = Sinatra::Application.root
    config.sass_dir     = File.join('views', 'stylesheets')
    # config.css_dir = "public/stylesheets/compiled"
    config.images_dir = File.join('public', 'images')
    # config.output_style = :compact
    config.http_images_path = "/images"
    config.http_path = "/"
    config.http_stylesheets_path = "/stylesheets"
  end
end

get "/stylesheets/screen.css" do
  content_type 'text/css'

  sass :"stylesheets/screen", Compass.sass_engine_options
end

get '/' do
  @background = "home"
  haml :home
end

get '/kontakt' do
  @background = "contact"
  haml :contact
end

get '/informacje' do
  @background = "info"
  haml :info
end

get '/galeria' do
  @background = "gallery"
  @galleries = Picasa.albums(:google_user => 'w.wnetrzak@gmail.com')
  @galleries.each_with_index do |gallery, i|
    @galleries[i][:slideshow] = Picasa.photos(:google_user => 'w.wnetrzak@gmail.com', :album_id => gallery[:id])[:slideshow]
  end
  haml :gallery
end
