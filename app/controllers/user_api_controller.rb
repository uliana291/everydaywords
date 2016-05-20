class UserApiController < ApiController

  def current
    render(json: current_user)
  end

end
