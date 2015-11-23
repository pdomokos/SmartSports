module Api::V1
  class ApiController < ActionController::Base
    before_action :doorkeeper_authorize!
    before_action :set_default_variables

    rescue_from Exception, :with => :general_error_handler
    respond_to :json

    include ResponseHelper
    include SaveClickRecord

    def current_resource_owner
      User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
    end

    def general_error_handler(ex)
      logger.error ex.message
      logger.error ex.backtrace.join("\n")
      render json: {msg: ex.message}, status: 400
    end

    private
    def set_default_variables
      @default_source = "smartdiab"

      lang = params[:lang]
      if lang
        I18n.locale=lang
      end

    end

  #

    def check_auth()
      if !owner?() && !doctor?()
        send_error_json(params[:id], "Unauthorized", 403)
        return false
      end
      return true
    end

    def check_doctor()
      if self.try(:current_resource_owner).try(:doctor?)
        return true
      end
      return false
    end
    alias_method :doctor?, :check_doctor

    def check_admin()
      if self.try(:current_resource_owner).try(:admin?)
        return true
      end
      return false
    end
    alias_method :admin?, :check_admin

    def check_owner()
      user_id = params[:user_id].to_i
      if self.try(:current_resource_owner).try(:id) == user_id
        return true
      end
      return false
    end
    alias_method :owner?, :check_owner

  end
end
