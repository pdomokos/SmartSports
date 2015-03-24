class OutlineController < ApplicationController

  def index
    uid = params[:user_id]
    summary = {}

    movesconn = Connection.where(user_id: uid, name: 'moves').first
    if not movesconn.nil?
      sess = JSON.parse(movesconn.data)

      @moves = Moves::Client.new(sess["token"])
      today = Date.today()
      dateFormat = "%Y-%m-%d"
      todayYmd = today.strftime(dateFormat)
      daily = @moves.daily_activities(todayYmd)

      if daily and daily[0] and daily[0]['summary']
        act_sum = daily[0]['summary']
        summary['cycling'] = getsum(act_sum, 'cycling', 'distance')
        summary['running'] = getsum(act_sum, 'running', 'distance')
        summary['walking'] = getsum(act_sum, 'walking', 'distance')
        summary['steps'] = getsum(act_sum, 'walking', 'steps')
        summary['distance'] = getsum(act_sum, nil, 'distance', true)/1000
        summary['activity'] = getsum(act_sum, nil, 'duration', true)
        summary['calories'] = getsum(act_sum, nil, 'calories', true)

        hourly = Hash.new
        for i in (0..23) do
          hourly[i] = 0
        end
        segments = daily[0]['segments']
        activities = []
        segments.each do |seg|
          activities = activities.concat(seg['activities'])
        end
        activities = activities.select { |act| act['activity']!= 'transport' and not act['steps'].nil? }
        activities.each do |act|
          add_steps_per_hour(hourly, act['steps'], act['startTime'], act['duration'])
        end
        prf = []
        (0..23).each do |hour|
          prf << {"time" => hour, "activity" => hourly[hour]}
        end
        summary[:profile] = prf
      end
    else
      sums = Summary.where("date between '#{todayYmd} 00:00:00' and '#{todayYmd} 23:59:59'")

      summary['cycling'] = 0
      summary['running'] = 0
      summary['walking'] =0
      summary['steps'] = 0
      summary['distance'] = 0
      summary['activity'] = 0
      summary['calories'] =0
      walk = sums.select{|it| it.group == 'walking'}
      if walk.length >0
        summary['walking'] = walk[0].total_duration
        summary['steps'] = walk[0].steps
        summary['calories'] = walk[0].calories
        summary['activity'] = walk[0].total_duration
        summary['distance'] = walk[0].distance
      end
    end

    respond_to do |format|
      format.json {render json: summary.to_json}
    end

  end

  def add_steps_per_hour(h, steps, start_time, duration)
    curr_hour = DateTime.parse(start_time).strftime("%H").to_i
    curr_min = DateTime.parse(start_time).strftime("%M").to_i
    steps_per_minute = steps/(duration/60.0)
    while duration>0
      minutes = 60-curr_min
      if duration/60 < minutes
        minutes = duration/60
      end
      h[curr_hour] = minutes*steps_per_minute

      curr_min = 0
      curr_hour += 1
      duration -= 60*minutes
    end
  end

  def getsum(arr, act_type, param, filter_transport = false)
    sel = arr
    if not act_type.nil?
      sel = arr.select{|it| it['activity'] == act_type}
    end
    if filter_transport
      sel = sel.select{|it| it['activity'] != 'transport'}
    end
    result = 0
    if not sel.empty?
      nums1 = sel.select{|it| not it[param].nil?}
      nums = nums1.collect {|it| it[param]}
      if not nums.empty?
        result = nums.sum
      end
    end
    return result
  end

  def fake_test
    if user
      summary = {
          :time => '2015-01-07 11:19',
          :steps => 1442,
          :cycling => 16.5,
          :running => 2.3,
          :calories => 424,
          :distance => 4.3,
          :activity =>  1241,
          :profile => (1..48).collect {|it| { 'time' => it/2.0, 'activity' => (rand()*60).round()}}
      }
    end

    respond_to do |format|
      format.json {render json: summary.to_json}
    end
  end
end
