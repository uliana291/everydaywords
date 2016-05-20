class UsersController < ApplicationController
  before_filter :set_user, only: [:show, :edit, :update]
  before_filter :validate_authorization_for_user

  # GET /users/1
  def show
  end

  # GET /users/1/edit
  def edit
  end

  def index
    @users = User.all
  end

  def update
  end

  def user_current
    #return 'hello world!'
    respond_to do |format|
      format.html { render html: "hello from html" }
      format.json { render json: ["hello from json", current_user.name] }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end


  def validate_authorization_for_user
    redirect_to root_path unless @user == current_user
  end


end
