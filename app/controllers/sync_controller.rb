class SyncController < ApplicationController
  include SyncWithings
  include SyncMoves
  include SyncFitbit
  include SyncGoogle
end
