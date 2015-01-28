class SyncController < ApplicationController
  include SyncWithings
  include SyncMoves
  include SyncFitbit
  include SyncGoogle

  def testmoves

  end
end
