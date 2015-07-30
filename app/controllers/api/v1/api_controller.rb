module Api::V1
  class ApiController < ActionController::Base
    before_action :doorkeeper_authorize!, only: [:profile]
    before_action :set_default_variables

    include ResponseHelper
    include SaveClickRecord

    def profile
      res = { :id => current_resource_owner.id,
              :member_since => current_resource_owner.created_at,
              :full_name => current_resource_owner.name,
              :email => current_resource_owner.email
      }
      if current_resource_owner.profile
        prf =current_resource_owner.profile
        res[:profile] = true
        res[:weight] = prf.weight
        res[:height] = prf.height
        res[:sex] = prf.sex
        res[:smoke] = prf.smoke
        res[:insulin] = prf.insulin
        res[:default_lang] = prf.default_lang
      else
        res[:profile] = false
      end
      res[:connections] = u.connections.collect{|it| it.name}
      render json: res
    end

    def current_resource_owner
      User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
    end

    def general_error_handler(ex)
      logger.error ex.message
      logger.error ex.backtrace.join("\n")
      render json: nil, status: 400
    end

    private
    def set_default_variables
      @default_source = "smartdiab"
    end
  end
end