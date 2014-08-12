require "Event"
require "Address"
require "Cache"
require "Util"
include Event
include Address
include Cache
include Util

class Update


  #
  # atnd
  #
  def self.atnd()
    puts "atnd開始"

    start_day, end_day = get_period()

    #today = Date.today
    #start_day = today - 1.days
    #end_day   = today + 1.days

    events = {}
    i = start_day
    while i < end_day do
      print sprintf('%d年%d月%d日', i.year, i.month, i.day)
      results = get_events_from_atnd(sprintf('%d%02d%02d', i.year, i.month, i.day), 1)
      puts results.length.to_s + "件"
      events.merge!(results)

      i = i + 1.days
      sleep(1)
    end

    cache_write(SITE_NAME[TYPE_ATND], classifyEventsWithArea(events.values))

    puts "atnd終了"
  end

  #
  # zusaar
  #
  def self.zusaar()
    puts $LOAD_PATH
    puts "zusaar開始"

    start_day, end_day = get_period()

    events = {}
    i = start_day
    while i < end_day.end_of_month do
      print sprintf('%d年%d月', i.year, i.month)
      results = get_events_from_zusaar(sprintf('%d%02d', i.year, i.month), 2)
      puts results.length.to_s + "件"

      events.merge!(results)

      i = i + 1.month
      sleep(2)
    end

    cache_write(SITE_NAME[TYPE_ZUSAAR], classifyEventsWithArea(events.values))

    puts "zusaar終了"
  end

  #
  # connpass
  #
  def self.connpass()
    puts "connpass開始"

    start_day, end_day = get_period()

    events = {}
    i = start_day
    while i < end_day.end_of_month do
      print sprintf('%d年%d月', i.year, i.month)
      results = get_events_from_connpass(sprintf('%d%02d', i.year, i.month), 2)
      puts results.length.to_s + "件"

      events.merge!(results)

      i = i + 1.month
      sleep(2)
    end

    cache_write(SITE_NAME[TYPE_CONNPASS], classifyEventsWithArea(events.values))

    puts "connpass終了"
  end

  #
  # doorkeeper
  #
  def self.doorkeeper()
    puts "doorkeeper開始"

    start_day, end_day = get_period()

    events = get_events_from_doorkeeper(start_day, end_day, 2)
    puts start_day.to_s + "〜" + end_day.to_s + " " + events.length.to_s + "件"

    cache_write(SITE_NAME[TYPE_DOORKEEPER], classifyEventsWithArea(events.values))

    puts "doorkeeper終了"
  end

  #
  # キャッシュクリア
  #
  def self.clear()

  end

  private

  #
  # 期間を取得する
  #
  def self.get_period()
    today = Date.today
    start_day = today - 7.days
    end_day   = today + MAX_MONTHS.month

    return start_day, end_day
  end

  #
  # イベント情報をエリアカテゴリ毎に分類する
  # ※ついでに参加者が0のイベントも取り除いておく
  #
  # [
  #   イベント1,
  #   イベント2,
  #   イベント3,
  #   ・・・,
  # ]
  # ↓
  # {
  #   1 => [
  #     イベント1,
  #     イベント2,
  #     ・・・,
  #   ],
  #   2 => [
  #     イベント3,
  #   ・・・
  # }
  #
  def self.classifyEventsWithArea(events)
    classified_events = {}

    area_to_category = {}
    AREA_CATEGORIES.each do |category, category_info|
      # 初期化
      classified_events[category] = []

      # {area => area_category, …}の形にする
      category_info[:list].each do |area, area_name|
        area_to_category[area.to_i] = category
      end
    end

    filterd_count = 0
    events.each do |event|
      if event[:area] then
        if event[:count] > 0 then
          category = area_to_category[event[:area]]
          classified_events[category].push(event)
        else
          filterd_count += 1
        end
      end
    end
    puts filterd_count.to_s + "件除外"

    return classified_events
  end

end