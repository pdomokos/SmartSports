class SyncConnectionJob < Struct.new(:connection, :user_id, :connection_id)

  def perform
    conn = Connection.find_by_id(connection_id)
    if conn.nil?
      Delayed::Worker.logger.error("#{connection} sync failed, connection #{connection_id} for user #{user_id} not found ")
    else
      Delayed::Worker.logger.info("SyncConnectionJob perform, conn: #{connection}, user_id: #{user_id}, conn_id: #{connection_id}")
      syncInstance = Object.const_get(connection.to_s.capitalize+"Synchronizer").new(user_id, connection_id, Delayed::Worker.logger)
      if syncInstance.sync(conn)
        conn.synced_at = DateTime.now
        conn.sync_status = Connection.sync_statuses[:success]
      else
        conn.sync_status = Connection.sync_statuses[:failure]
      end
      conn.save!
    end
  end

  def max_attempts
    1
  end

end
