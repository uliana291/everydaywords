class UserController < ApiController

  def current
    render(json: current_user)
  end

  def show
    if !current_user
      render :json => {:error => 'not-found'}, :status => 500
    else
      render(json: current_user)
    end
  end

  def update
    if !current_user
      render :json => {:error => 'not-found'}, :status => 500
    else
      current_user.name = params[:name]
      current_user.email = params[:email]
      if current_user.save
        render(json: current_user)
      else
        render :json => {:error => 'internal-server-error'}, :status => 500
      end
    end
  end

end
