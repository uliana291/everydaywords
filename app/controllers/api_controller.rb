class ApiController < ActionController::Metal
  abstract!
  require 'fileutils'

  include AbstractController::Callbacks
  include ActionController::RackDelegation
  include ActionController::StrongParameters

  before_action :authorize_touch

  def ping
    render :json => {:result => { 'response' => 'pong' }}, :status => 200
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
      ENV['LAST_ACTIVITY_FILE_PATH']
      FileUtils.touch(ENV['LAST_ACTIVITY_FILE_PATH'])
    end
  end

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def not_found
    return api_error(status: 404, errors: 'Not found')
  end

  ActiveSupport.run_load_hooks(:action_controller, self)
end