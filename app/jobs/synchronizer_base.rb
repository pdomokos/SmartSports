class SynchronizerBase
  attr_reader :logger
  attr_reader :user_id
  attr_reader :connection_id
  attr_reader :dateFormat
  attr_reader :client
  def initialize(user_id, connection_id, logger)
    @user_id = user_id
    @connection_id = connection_id
    @logger = logger
    @dateFormat = "%F"
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

  def remove_summaries_from_date(source, date, group=nil)
    to_remove = Summary.where("user_id= #{user_id} and source = '#{source}' and date>=?",
                              Date.parse(date).midnight.strftime("%F %T"))
    if not group.nil?
      to_remove = to_remove.where(group: group)
    end

    ret = to_remove.delete_all
    logger.info("removed #{ret} records from #{source} summaries")
    return ret
  end
  def remove_measurements_from_date(source, date)
    to_remove = Measurement.where("user_id= #{user_id} and source = '#{source}' and date>=?",
                              Date.parse(date).midnight.strftime("%F %T"))
    ret = to_remove.delete_all
    return ret
  end
  def get_last_summary_date(source, group)
    u = User.find_by_id(user_id)
    s = u.summaries.where(source: source).where(group: group).order(date: :desc).limit(1).first
    s.try(:date)
  end
  def get_last_measurement_date(source)
    u = User.find_by_id(user_id)
    s = u.measurements.where(source: source).order(date: :desc).limit(1).first
    s.try(:date).try(:to_datetime)
  end
end