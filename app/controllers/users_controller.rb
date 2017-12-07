class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_owner!, except: [:show, :index]

  # GET /users
  def index
    @users = User.page(params[:page]).per(6)
  end

  # GET /users/1
  def show
    @tweets = @user.tweets.page(params[:page]).per(10)
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to @user, notice: 'User was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
    redirect_to users_url, notice: 'User was successfully destroyed.'
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:name, :email, :avatar)
  end

  def authenticate_owner!
    return if current_user == @user
    flash[:alert] = "This action is not allowed"
    redirect_back fallback_location: root_path
  end
end
