class TweetsController < ApplicationController
  before_action :set_user, only: [:edit, :create, :update, :destroy]
  before_action :set_tweet, only: [:edit, :update, :destroy]

  def index
    @tweets = Tweet.order(created_at: 'desc').eager_load(:user).page(params[:page]).per(3)
  end

  def show
  end

  def new
    @tweet = Tweet.new
  end

  def edit
  end

  def create
    @tweet = Tweet.new(tweet_params)
    @tweet.user_id = @user.id

    if @tweet.save
      redirect_to root_path, notice: 'Tweet was successfully created.'
    else
      render :new
    end
  end

  def update
    if @tweet.update(tweet_params)
      redirect_to root_path, notice: 'Tweet was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @tweet.destroy
    redirect_to tweets_url, notice: 'Tweet was successfully destroyed.'
  end

  private
  def set_tweet
    @tweet = @user.tweets.find(params[:id])
  end

  def set_user
    @user = current_user
    unless @user && params[:user_id] == @user.id.to_s
      redirect_to root_path, alert: "Invalid action"
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def tweet_params
    params.require(:tweet).permit(:body)
  end
end
