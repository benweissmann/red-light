$:.push File.dirname(__FILE__)


require 'sinatra'
require 'light-controller'
require 'yaml'


set :environment, :production
set :port, 80
set :bind, '0.0.0.0'

COLORS = {
  nil                            => "off",
  LightController::RED           => "red",
  LightController::ORANGE        => "orange",
  LightController::YELLOW        => "yellow",
  LightController::GREEN         => "green",
  LightController::BLUE          => "blue",
  LightController::PURPLE        => "purple",
  LightController::INVALID_STATE => "unkown",
  LightController::CYCLING       => "rainbow"
}

AUTH_CONFIG = DB_PARAMS = YAML::load(File.open(File.join(File.dirname(__FILE__), 'auth.yml')))

helpers do
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    return (
      @auth.provided?   and
      @auth.basic?      and
      @auth.credentials and
      @auth.credentials == [AUTH_CONFIG['username'], AUTH_CONFIG['password']]
    )
  end
end

before do
  @color = COLORS[LightController.get_color]
end

get '/' do
  haml :home
end

get '/admin' do
  protected!
  haml :admin
end

post '/admin' do
  protected!

  begin
    if params['color'] == "off"
      LightController.reset
    elsif params['color'] == "rainbow"
      LightController.rainbow
    else
      LightController.set_color params['color'].to_i
    end
  rescue
    return "Invalid request"
  end

  @color = COLORS[LightController.get_color]
  haml :admin
end
