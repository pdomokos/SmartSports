module Api::V1
  class PasswordResetsController < ApiController
    before_action :doorkeeper_authorize!, except: 'create'

    include PasswordResetsCommon

  end
end