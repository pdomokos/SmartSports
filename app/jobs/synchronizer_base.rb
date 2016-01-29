class SynchronizerBase
  attr_reader :logger
  attr_reader :user_id
  attr_reader :connection_id
  def initialize(user_id, connection_id, logger)
    @user_id = user_id
    @connection_id = connection_id
    @logger = logger
  end

  def get_last_synced_final_date(source, group=nil)
    last_sync_date = nil
    query = Summary.where(user_id: user_id).where(source: source)
    if not group.nil?
      query = query.where(group: group)
    end
    query = query.where("sync_final = 't'").order(date: :desc).limit(1)
    if query.size() > 0
      last_sync = query[0]
      last_sync_date = last_sync.date
    end
    return last_sync_date
  end

  def get_last_synced_tracker_final_date(source, group=nil)
    last_sync_date = nil
    dateFormat = "%Y-%m-%d"
    query = TrackerDatum.where(user_id: user_id).where(source: source)
    if not group.nil?
      query = query.where(group: group)
    end
    query = query.where("sync_final = 't'").order(start_time: :desc).limit(1)
    if query.size() > 0
      last_sync = query[0]
      last_sync_date = last_sync.start_time
      last_sync_date = last_sync_date.strftime(dateFormat)
    end
    return last_sync_date
  end
end