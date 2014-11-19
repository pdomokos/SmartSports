class FriendshipsController < ApplicationController
  def index
    uid = params[:user_id]
    @user = User.find(uid)
    @friendships = Friendship.where("user1_id = #{uid} or user2_id = #{uid}")
  end

  def new
    @friendship = Friendship.new
  end

  def create
    user1 = current_user
    user2 = User.where("username = '#{params[:friend_name]}'").first
    @friendship = nil
    if user2
      @friendship = Friendship.new({:user1_id => user1.id, :user2_id => user2.id, :authorized => false})
    end

    respond_to do |format|
      if @friendship and @friendship.save
        puts "save ok"
        notif1 = Notification.new({:user_id => user1.id, :title => "Friend", :detail => "Friend request sent to #{user2.username}", :notification_type =>"friend", :date => DateTime.now()})
        notif1.save!
        notif2 = Notification.new({:user_id => user2.id, :title => "Friend",
                                   :detail => "New friend request from #{user1.username}", :notification_type =>"friend", :date => DateTime.now(),
                                   :notification_data => { "notif_type" => "friendreq", "friendshipid" => @friendship.id }.to_json
                                    })
        notif2.save!
        format.html { redirect_to user_friendships_path(current_user) }
        format.json { render :show, status: :created, location: @friend }
      else
        puts "save NOK"
        format.html {  redirect_to user_friendships_path(current_user) }
        format.json { render json: @friendship.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    if params[:cmd] == 'activate'
      @friendship = Friendship.find(params[:id])
      if current_user.id = @friendship.user2.id
        @friendship.authorized = true
        ret = @friendship.save!
        if not ret
          puts "failed to activate"
        end
        respond_to do |format|
          format.html { redirect_to user_friendships_path(current_user)}
          format.json { head :no_content }
        end
      else
        respond_to do |format|
          format.html { redirect_to user_friendships_path(current_user), notice: 'Failed to activate.' }
          format.json { head :no_content }
        end
      end
    end
  end


  # DELETE /measurements/1
  # DELETE /measurements/1.json
  def destroy
    uid = params[:user_id]
    user = User.find(uid)
    f = Friendship.find(params[:id])
    if user.id == current_user.id
      f.destroy
      respond_to do |format|
        format.html { redirect_to user_friendships_url(user), notice: 'Measurement was successfully destroyed.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to user_friendships_url(user), notice: 'Failed to destroy.' }
        format.json { head :no_content }
      end
    end
  end

  private

  def friendship_params
    params.require(:friendship).permit(:user1_id, :user2_id, :authorized)
  end
end
