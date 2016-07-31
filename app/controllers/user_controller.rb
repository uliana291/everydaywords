class UserController < ApiController

  def current
    render(json: current_user)
  end

  def show
    if !current_user
      render :json => {:error => 'not-found'}, :status => 500
    else
      user = current_user.attributes
      languages = []
      current_user.languages.each do |l|
       languages.push({:id => l.id})
      end
      user[:languages] = languages
      render :json => user
    end
  end

  def update
    if !current_user
      render :json => {:error => 'not-found'}, :status => 500
    else
      if current_user.update_attributes(user_params)
        if params[:languages]
          selected_languages = []
          params[:languages].each do |l|
            selected_languages.push(Language.find(l[:id]))
          end
          current_user.languages = selected_languages
        end
        render(json: current_user)
      else
        render :json => {:error => 'internal-server-error'}, :status => 500
      end
    end
  end

  private
  def user_params
    params.permit(:name, :email, :about,
                  :age, :about, :min_starts, :day_words)
  end

end