class FriendshipsController < ApplicationController
  def index
  end

  def new
    @friendship = Friendship.new
  end

  def create
    @friendship = Friendship.new(friendship_params)

    respond_to do |format|
      if @friendship.save
        format.html { redirect_to :controller => 'pages', :action => 'friendship' }
        format.json { render :show, status: :created, location: @friend }
      else
        format.html { redirect_to :controller => 'pages', :action => 'friendship' }
        format.json { render json: @friendship.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
  end

  private

  def friendship_params
    params.require(:friendship).permit(:user1_id, :user2_id, :authorized)
  end
end
