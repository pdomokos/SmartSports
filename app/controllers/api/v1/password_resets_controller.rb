module Api::V1
  class PasswordResetsController < ApiController
    rescue_from Exception, :with => :general_error_handler
    respond_to :json

    include PasswordResetsCommon

  end
end