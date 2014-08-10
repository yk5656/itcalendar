require "pp"
require "time"
require "active_support"

module Event

  #
  # ATNDのイベントを取得する
  #
  def get_events_from_atnd(ymd, interval)
    return get_events_from_common(
        TYPE_ATND,
        'http://api.atnd.org/events/',
        'http://atnd.org/events/',
        ymd, interval, 10
    )
  end

  #
  # Zusaarのイベントを取得する
  #
  def get_events_from_zusaar(ym, interval)
    return get_events_from_common(
        TYPE_ZUSAAR,
        'http://www.zusaar.com/api/event/',
        'http://www.zusaar.com/event/',
        ym, interval, 100
    )
  end

  #
  # connpassのイベントを取得する
  #
  def get_events_from_connpass(ym, interval)
    return get_events_from_common(
        TYPE_CONNPASS,
        'http://connpass.com/api/v1/event/',
        'http://connpass.com/event/',
        ym, interval, 100
    )
  end

  #
  # Doorkeeperのイベントを取得する
  #
  def get_events_from_doorkeeper(start_day, end_day, interval = 1)
    events = {}
    type = TYPE_DOORKEEPER
    url_api = 'http://api.doorkeeper.jp/events'

    # オプション設定
    options = {:since => start_day, :until => end_day, :page => 1}

    while events.size < MAX_EVENTS do
      # イベント取得
      results = get_events(type, url_api, options)
      events.merge!(results)

      # 件数チェック
      if results.length == 0 then
        return events
      end

      # 再取得
      options[:page] += 1
      sleep(interval) if interval
    end

    return events
  end

  #
  # ATND/Zusaar/connpassの共通のイベント取得
  #
  def get_events_from_common(type, url_api, url_event, ym, interval = 1, limit = 10)
    events = {}

    # オプション設定
    options = {:format => 'json', :count => limit, :start => 1}
    if ym.size == 8 then
      options[:ymd] = ym
    else
      options[:ym] = ym
    end

    while events.size < MAX_EVENTS do
      # イベント取得
      results = get_events(type, url_api, options, url_event)
      events.merge!(results)

      # 件数チェック
      if results.length < limit then
        return events
      end

      # 再取得
      options[:start] += limit
      sleep(interval) if interval
    end

    return events
  end


  #
  # イベント情報を取得する
  #
  def get_events(type, url_api, options, url_event = nil)
    events = {}

    # イベント取得
    json = get_json(url_api, options)

    # イベントのリスト取得
    if json.class.to_s == "Hash" then
      if json.has_key?(:events) then
        json = json[:events]
      elsif json.has_key?(:event)
        json = json[:event]
      end
    end

    json.each do |event_array|
      # イベント情報取得
      e = event_array
      if e.has_key?(:event) then
        e = e[:event]
      end

      # id
      event_id = nil
      if e.has_key?(:event_id) then
        event_id = e[:event_id]
      elsif e.has_key?(:id) then
        event_id = e[:id]
      end

      # start・end
      start_at = nil
      end_at = nil
      if e.has_key?(:started_at) then
        start_at = Time.parse(e[:started_at])
      elsif e.has_key?(:starts_at) then
        start_at = Time.parse(e[:starts_at]).in_time_zone('Asia/Tokyo')
      end
      if e.has_key?(:ended_at) then
        end_at = Time.parse(e[:ended_at]) if e[:ended_at]
      elsif e.has_key?(:ends_at) then
        end_at = Time.parse(e[:ends_at]).in_time_zone('Asia/Tokyo') if e[:ends_at]
      end

      # date
      date = start_at.strftime('%Y-%m-%d')

      # title
      title = e[:title]

      # url
      url = nil
      if e.has_key?(:public_url) then
        url = e[:public_url]
      elsif url_event && e.has_key?(:event_id) then
        url = url_event + e[:event_id].to_s
      end

      # limit
      limit = nil
      if e.has_key?(:ticket_limit) then
        limit = e[:ticket_limit]
      elsif e.has_key?(:limit) then
        limit = e[:limit]
      end

      # count
      count = 0
      count += e[:participants] if e.has_key?(:participants)
      count += e[:waitlisted]   if e.has_key?(:waitlisted)
      count += e[:accepted]     if e.has_key?(:accepted)
      count += e[:waiting]      if e.has_key?(:waiting)

      # address・area
      address = e[:address]
      area = get_area_from_address(address)

      # owner_id
      owner_id = nil
      if e.has_key?(:group) && e[:group].has_key?(:id) then
        owner_id = e[:group][:id]
      elsif e.has_key?(:owner_id) then
        owner_id = e[:owner_id]
      end

      # event組み立て
      event = {
          :event_id => event_id,
          :type     => type,
          :date     => date,
          :title    => title,
          :url      => url,
          :limit    => limit,
          :count    => count,
          :start    => start_at,
          :end      => end_at,
          :address  => address,
          :area     => area,
          :owner_id => owner_id,
      }
      events[event_id] = event
    end

    return events
  end




end