module Api::V1
  class LifestylesController < ApiController
    before_action :set_lifestyle, only: [ :update, :destroy]
    before_action :check_valid_user, only: [:index]

    include LifestylesCommon

    def index
      get_lifestyles()
      render :template => '/lifestyles/index.json'
    end
  end
end
