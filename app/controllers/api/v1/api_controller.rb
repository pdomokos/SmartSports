module Api::V1
  class ApiController < ActionController::Base
    before_action :doorkeeper_authorize!, only: [:profile]
    before_action :set_default_variables

    def profile
      render json: { :id => current_resource_owner.id,
                     :member_since => current_resource_owner.created_at,
                     :full_name => current_resource_owner.name,
                     :email => current_resource_owner.email
      }
    end

    def current_resource_owner
      User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
    end

    private
    def set_default_variables
      @default_source = "smartdiab"
    end
  end
end