class SyncController < ApplicationController
  before_action :check_owner

  include SyncWithings
  include SyncMoves
  include SyncFitbit
  include SyncMisfit
  include SyncGoogle

end
