class WelcomeController < ApplicationController
  def index
    render :file => 'public/index.html.erb'
  end

  def user_current
    respond_to do |format|
      format.html { render html: "hello from html" }
      format.json { render json: ["hello from json", current_user.name, current_user.id] }
    end
  end

end
