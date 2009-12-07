%w(rubygems sinatra haml sass compass).each { |dependency| require dependency }

configure do
  set :haml, { :format => :html5 }
  Compass.configuration do |config|
    config.project_path = File.dirname(__FILE__)
    config.sass_dir     = File.join('views', 'stylesheets')
    # config.css_dir = "public/stylesheets/compiled"
    config.images_dir = File.join('public', 'images')
    # config.output_style = :compact
    config.http_images_path = "/images"
  end
end

get "/stylesheets/screen.css" do
  content_type 'text/css'

  # Use views/stylesheets & blueprint's stylesheet dirs in the Sass load path
  sass :"stylesheets/screen", :sass => Compass.sass_engine_options
end

get '/' do
  haml :home
end