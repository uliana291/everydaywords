class ApiController < ActionController::Metal
  abstract!
  require 'fileutils'
  require 'json'

  include AbstractController::Callbacks
  include ActionController::RackDelegation
  include ActionController::StrongParameters

  before_action :authorize_touch
  before_filter :cors_preflight_check
  after_filter :cors_set_access_control_headers

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  def cors_preflight_check
    if request.method == 'OPTIONS'
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
      headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version, Token'
      headers['Access-Control-Max-Age'] = '1728000'

      render :text => '', :content_type => 'text/plain'
    end
  end

  def ping
    render :json => {:result => { 'response' => 'pong' }}, :status => 200
  end

  def proxy_request
    if !current_user
      return api_error(status: 403, errors: 'Not authorized')  
    end

    url = URI.parse(params[:url])
    if params[:method] == 'GET'
      req = Net::HTTP::Get.new(url.to_s)
    elsif params[:method] == 'POST'  
      req = Net::HTTP::Post.new(url.to_s)
      if not params[:body].nil?
        req.body = params[:body]  
      end    
    end 
    if not params[:headers].nil? 
      params[:headers].each do |header|
        if !header.nil?
          req[header[:name]] = header[:value]
        end  
      end    
    end

    http = Net::HTTP.new(url.host, url.port)
    if url.scheme == 'https'
      http.use_ssl = true  
    end    

    res = http.request(req)
    puts res.body
    puts res.body.encoding
    res_body = res.body

    if params[:url].include? "multitran"
        res_body = res_body.force_encoding("cp1251").encode("utf-8")
    end    

    render :json => {:result => { 
      'body' => res_body,
      'code' => res.code
    }}, :status => 200  
  end    

  private

  def render(options={})
    self.status = options[:status] || 200
    self.content_type = 'application/json'
    body = Oj.dump(options[:json], mode: :compat)
    self.headers['Content-Length'] = body.bytesize.to_s
    self.response_body = body
  end

  def authorize_touch
    if current_user
      puts [ENV].to_json
      FileUtils.touch(ENV['LAST_ACTIVITY_FILE_PATH'])
    end
  end

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def not_found
    return api_error(status: 404, errors: 'Not found')
  end

  ActiveSupport.run_load_hooks(:action_controller, self)
end
