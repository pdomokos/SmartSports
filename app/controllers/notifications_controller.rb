class NotificationsController < ApplicationController
  before_action :set_notification, only: [:show, :edit, :update, :destroy]

  include NotificationsCommon

  # GET /notifications
  # GET /notifications.json
  def index
    user_id = params[:user_id]
    @patient = false
    if params[:patient] && params[:patient]=='true'
      @patient = true
    end
    print "PATIENT: #{@patient}"
    @user = User.find(user_id)
    @notifications = @user.notifications
    lang = params[:lang]
    if lang
      I18n.locale=lang
    end
    if params[:upcoming] && params[:upcoming]=='true'
      @notifications = @notifications.where('date > ?', Time.zone.now)
    end
    if params[:order] && params[:order]=='asc'
      @notifications = @notifications.order(created_at: :asc)
    else
      @notifications = @notifications.order(created_at: :desc)
    end
  end

  # GET /notifications/1
  # GET /notifications/1.json
  def show

  end

  # GET /notifications/new
  def new
    user_id = params[:user_id]
    @user = User.find(user_id)
    @notification = @user.notifications.create
  end

  # GET /notifications/1/edit
  def edit
  end

  # POST /notifications
  # POST /notifications.json

end
