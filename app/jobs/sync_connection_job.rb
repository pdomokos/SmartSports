class SyncConnectionJob < Struct.new(:connection, :user_id, :connection_id)

  def perform
    Delayed::Worker.logger.info("SyncConnectionJob perform, conn: #{connection}, user_id: #{user_id}, conn_id: #{connection_id}")
    Object.const_get(connection.to_s.capitalize+"Synchronizer").send(:sync, user_id, connection_id)
  end

  def max_attempts
    1
  end

end
