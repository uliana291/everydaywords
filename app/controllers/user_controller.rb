require "active_support/core_ext/hash/keys"
require "action_dispatch/middleware/session/abstract_store"
require "rack/session/cookie"

class UserController < ApiController

  def current
    if !current_user and ENV.fetch('DEV_ALLOW_GUEST_LOGIN', '0') == '1'
      render(json: {:id => -1,:name => "dev", :email => "dev@local.local", :admin => true})
    else
      response = current_user.as_json
      response[:session_id] = request.cookie_jar['_everydaywords_session']
      render(json: response)
    end  
  end

  def restore_session
    request.cookie_jar['_everydaywords_session'] = params[:saved_session_id]
    data = request.cookie_jar.signed_or_encrypted['_everydaywords_session']
    user_id = data["warden.user.user.key"][0][0]
    puts "restoring session for #{user_id}"
    sign_in(:user, User.find(user_id))
    render(json: current_user)
  end

  def list
    if not current_user.nil? and current_user.admin? or ENV.fetch('DEV_ALLOW_GUEST_LOGIN', '0') == '1'
      users = User.all
      render(json: users)
    end
  end

  def become
    return unless not current_user.nil? and current_user.admin? or ENV.fetch('DEV_ALLOW_GUEST_LOGIN', '0') == '1' 
    sign_in(:user, User.find(params[:id]))
    render(json: current_user)
  end

  def show
    if !current_user
      render :json => {:error => 'not-found'}, :status => 500
    else
      user = (params[:id]? User.find(params[:id]) : current_user)
      user_attributes = user.attributes
      languages = []
      user.languages.each do |l|
       languages.push({:id => l.id})
      end
      user_attributes[:finished_words] = user.user_translations.where(learning_stage: 'finished').count
      user_attributes[:streak] = user_streak(user)
      user_attributes[:languages] = languages
      render :json => user_attributes
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


  def user_streak(user)
    trainings = user.trainings.where(state: 'finished').order('created_at DESC')
    dates = trainings.map(&:created_at)
    dates.uniq!
    if !dates.nil?
    max = 1
    today = Date.today
    dates.each do |date|
      if date.to_date == today
        max = 1
      elsif (date.to_date == today - max)
        max = max + 1
      elsif (max > 1)
        break
      end
    end
    if (dates.first.to_date < (today - 1))
      max = 0
    end
    else
      max = 0
    end
    max
  end

end
