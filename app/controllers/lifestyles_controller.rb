class LifestylesController < ApplicationController
  before_action :set_lifestyle, only: [:show, :edit, :update, :destroy]
  before_action :check_valid_user, only: [:index]

  include LifestylesCommon

  def index
    get_lifestyles()
  end

  # GET /lifestyles/1
  # GET /lifestyles/1.json
  def show
  end

end
