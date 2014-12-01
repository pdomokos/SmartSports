class FriendshipsController < ApplicationController
  def index
    uid = params[:user_id]
    filter = params[:filter]
    @user = User.find(uid)
    @friendships = Friendship.where("user1_id = #{uid} or user2_id = #{uid}")

    if filter and filter=="auth"
      @friendships = @friendships.where("authorized = 't'")
    end

    if filter and filter=="my"
      @friendships = @friendships.where("authorized = 't' and user2_id = #{uid}")
    end


    data = @friendships.collect do |f|
      puts "uid="+uid+" f.user1_id="+f.user1_id.to_s
      other = f.user1
      invited = true
      if f.user1.id == uid.to_i
        other = f.user2
        invited = false
      end
      { :my_id => uid, :other_id => other.id, :other_name => other.username, :authorized => f.authorized, :id=> f.id, :invited => invited}
    end

    respond_to do |format|
      format.html
      format.json { render json: data }
    end
  end

  def new
    @friendship = Friendship.new
  end

  def create
    user1 = current_user
    user2 = User.where("username = '#{params[:friend_name]}'").first
    failed = false
    @friendship = nil

    if not user2
      failed = true
      msg = "Friend '#{params[:friend_name]}' not found."
    end

    if not failed and  user1.id==user2.id
      failed = true
      msg = "Can not make yourself a friend"
    end

    if not failed
      f = Friendship.where("( user1_id = #{user1.id} and user2_id = #{user2.id} ) or ( user1_id = #{user2.id} and user2_id = #{user1.id} )")
      if f and f.size >0
        failed = true
        msg = "Friend already."
      end
    end

    if not failed
      @friendship = Friendship.new({:user1_id => user1.id, :user2_id => user2.id, :authorized => false})
      ret = @friendship.save
      if not ret
        failed = true
        msg = "Failed to add friendship"
      end
    end

    respond_to do |format|
      if not failed
        puts "save ok"
        notif1 = Notification.new({:user_id => user1.id, :title => "Friend", :detail => "Friend request sent to #{user2.username}", :notification_type =>"friend", :date => DateTime.now()})
        notif1.save!
        notif2 = Notification.new({:user_id => user2.id, :title => "Friend",
                                   :detail => "New friend request from #{user1.username}", :notification_type =>"friend", :date => DateTime.now(),
                                   :notification_data => { "notif_type" => "friendreq", "friendshipid" => @friendship.id }.to_json
                                    })
        notif2.save!
        format.html { redirect_to user_friendships_path(current_user) }
        format.json { render json: {:status => "OK", :friendship => @friendship } }
      else
        puts "save NOK"
        format.html {  redirect_to user_friendships_path(current_user) }
        format.json { render json: { :status => "NOK", :msg => msg } }
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
