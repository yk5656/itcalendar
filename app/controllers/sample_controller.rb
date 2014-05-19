require "open-uri"
require "time"
require "active_support"

class SampleController < ApplicationController

  TYPE_ATND       = 1
  TYPE_ZUSAAR     = 2
  TYPE_CONNPASS   = 3
  TYPE_DOORKEEPER = 4

  SITE_NAME = {
    TYPE_ATND       => 'ATND',
    TYPE_ZUSAAR     => 'Zusaar',
    TYPE_CONNPASS   => 'connpass',
    TYPE_DOORKEEPER => 'Dookeeper',
  }

  AREA_HOKKAIDO_TOHOKU = 1
  AREA_KANTO           = 2
  AREA_CHUBU           = 3
  AREA_KANSAI          = 4
  AREA_CHUGOKU_SHIKOKU = 5
  AREA_KYUSHU_OKINAWA  = 6

  AREA_CATEGORIES = {
    AREA_HOKKAIDO_TOHOKU => {:action => 'hokkaido_tohoku',  :name => '北海道・東北'},
    AREA_KANTO           => {:action => 'kanto',            :name => '関東'},
    AREA_CHUBU           => {:action => 'chubu',            :name => '中部'},
    AREA_KANSAI          => {:action => 'kansai',           :name => '関西'},
    AREA_CHUGOKU_SHIKOKU => {:action => 'chugoku_shikoku',  :name => '中国・四国'},
    AREA_KYUSHU_OKINAWA  => {:action => 'kyushu_okinawa',   :name => '九州・沖縄'},
  }

  NG_OWNER_ID = {
    TYPE_ATND       => {
    },
    TYPE_ZUSAAR     => {
    },
    TYPE_CONNPASS   => {
    },
    TYPE_DOORKEEPER => {
      1888 => true,       #COOK COOP BOK STUDIO
      1055 => true,       #Akakura Baby & Kids Club あかくら
    },
  }

  AREA_KEYWORDS = {
    AREA_HOKKAIDO_TOHOKU => {
       1 => {:name => ['北海道', '札幌'], :key => ['北海道', '札幌市']},
       2 => {:name => ['青森'],           :key => ['青森県']},
       3 => {:name => ['岩手'],           :key => ['岩手県']},
       4 => {:name => ['宮城'],           :key => ['宮城県']},
       5 => {:name => ['秋田'],           :key => ['秋田県']},
       6 => {:name => ['山形'],           :key => ['山形県']},
       7 => {:name => ['福島', '仙台'],   :key => ['福島県', '仙台市']},
    },
    AREA_KANTO => {
      13 => {:name => ['東京'],           :key => ['東京', 'tokyo']},
      14 => {:name => ['神奈川', '横浜', '川崎'], :key => ['神奈川県', '横浜市', '川崎市']},
      11 => {:name => ['埼玉'],           :key => ['埼玉県']},
      12 => {:name => ['千葉', '船橋'],   :key => ['千葉県', '船橋市']},
       8 => {:name => ['茨城'],           :key => ['茨城県']},
       9 => {:name => ['栃木'],           :key => ['栃木県']},
      10 => {:name => ['群馬'],           :key => ['群馬県']},
    },
    AREA_CHUBU => {
      23 => {:name => ['愛知', '名古屋'], :key => ['愛知県', '名古屋市']},
      22 => {:name => ['静岡', '浜松'],   :key => ['静岡県', '浜松市']},
      21 => {:name => ['岐阜'],           :key => ['岐阜県']},
      20 => {:name => ['長野'],           :key => ['長野県']},
      16 => {:name => ['富山'],           :key => ['富山県']},
      17 => {:name => ['石川', '金沢'],   :key => ['石川県', '金沢市']},
      18 => {:name => ['福井'],           :key => ['福井県']},
      15 => {:name => ['新潟'],           :key => ['新潟県']},
      19 => {:name => ['山梨'],           :key => ['山梨県']},
    },
    AREA_KANSAI => {
      27 => {:name => ['大阪', '堺市'],   :key => ['大阪府', '堺市']},
      28 => {:name => ['兵庫', '神戸'],   :key => ['兵庫県', '神戸市']},
      26 => {:name => ['京都'],           :key => ['京都府']},
      25 => {:name => ['滋賀'],           :key => ['滋賀県']},
      29 => {:name => ['奈良'],           :key => ['奈良県']},
      30 => {:name => ['和歌山'],         :key => ['和歌山']},
      24 => {:name => ['三重'],           :key => ['三重県']},
    },
    AREA_CHUGOKU_SHIKOKU => {
      34 => {:name => ['広島'],           :key => ['広島県']},
      33 => {:name => ['岡山'],           :key => ['岡山県']},
      31 => {:name => ['鳥取'],           :key => ['鳥取県']},
      32 => {:name => ['島根'],           :key => ['島根県']},
      35 => {:name => ['山口'],           :key => ['山口県']},
      37 => {:name => ['香川'],           :key => ['香川県']},
      38 => {:name => ['愛媛', '松山'],   :key => ['愛媛県', '松山市']},
      36 => {:name => ['徳島'],           :key => ['徳島県']},
      39 => {:name => ['高知'],           :key => ['高知県']},
    },
    AREA_KYUSHU_OKINAWA  => {
      40 => {:name => ['福岡', '博多', '北九州'],   :key => ['福岡県', '博多', '北九州市']},
      43 => {:name => ['熊本'],           :key => ['熊本県']},
      42 => {:name => ['長崎'],           :key => ['長崎県']},
      41 => {:name => ['佐賀'],           :key => ['佐賀県']},
      44 => {:name => ['大分'],           :key => ['大分県']},
      45 => {:name => ['宮崎'],           :key => ['宮崎県']},
      46 => {:name => ['鹿児島'],         :key => ['鹿児島']},
      47 => {:name => ['沖縄'],           :key => ['沖縄県']},
    },
  }

  MAX_MONTHS  = 2
  MAX_EVENTS  = 1000
  EXPIRE_SEC  = 1*60

  def index
    calendar(AREA_KANTO)
  end
  def hokkaido_tohoku
    render 'index'
  end
  def kanto
    calendar(AREA_KANTO)
    render 'index'
  end
  def chubu
    calendar(AREA_CHUBU)
    render 'index'
  end
  def kansai
    calendar(AREA_KANSAI)
    render 'index'
  end
  def chugoku_shikoku
    calendar(AREA_CHUGOKU_SHIKOKU)
    render 'index'
  end
  def kyushu_okinawa
    calendar(AREA_KYUSHU_OKINAWA)
    render 'index'
  end

  def clear_cache
    Rails.cache.clear()
    render :json => {:msg => 'キャッシュをクリアーしました'}
  end

  def update_cache
    @error_msg = []
    @debug_log = []
    msg = ''

    today = Date.today
    start_day = today
    end_day   = today + (MAX_MONTHS - 1).month

    events = nil

    type = params[:type].to_i
    area_category = nil
    if params[:area_category] then
      area_category = params[:area_category].to_i
    end

    case type
    when TYPE_ATND
      updated, events, clear_flag = get_events(type, area_category, start_day, end_day, false)
      if clear_flag then
        msg += 'ATND(' + area_category.to_s + ') '
      end

    when TYPE_ZUSAAR
      updated, events, clear_flag = get_events(type, nil, start_day, end_day, true)
      if clear_flag then
        msg += 'Zusaar '
      end

    when TYPE_CONNPASS
      if params[:area_category] then
        updated, events, clear_flag = get_events(type, area_category, start_day, end_day, true)
        if clear_flag then
          msg += 'connpass(' + area_category.to_s + ') '
        end
      end

    when TYPE_DOORKEEPER
      updated, events, clear_flag = get_events(type, nil, start_day, end_day, true)
      if clear_flag then
        msg += 'Dookeeper '
      end
    end

    if events then
      msg = 'update : ' + msg
    else
      msg = 'no update'
    end

    render :json => {:msg => msg}
  end

  private

  def get_cache_key(type, area_category)
  end
  def get_event_common(type, start_day, end_day, area_list)
  end

  def get_area_list(area_category)
    area_list = []
    AREA_KEYWORDS[area_category].each do |a,keywords|
      area_names = keywords[:name]
      area_names.each do |key|
        area_list.push key
      end
    end
    return area_list
  end

  def get_area_name(area_category)
    area_name = {}
    AREA_KEYWORDS[area_category].each do |a,keywords|
      area_names = keywords[:name]
      area_name[a] = area_names[0]
    end
    return area_name
  end

  def calendar(area_category)
    @error_msg = []
    @debug_log = []

    @option_monday = (cookies[:m]) ? true : false
    @option_blank  = true
    @option_count = (cookies[:c]) ? cookies[:c].to_i : 1
    @option_limit = (cookies[:l]) ? cookies[:l].to_i : 0
    @option_full  = (cookies[:f] && cookies[:f].to_i > 0) ? true: false

    option_areas = {}
    area_key = 'a' + area_category.to_s
    if cookies[area_key] then
      area = cookies[area_key]
      AREA_KEYWORDS[area_category].keys.each do |a|
        option_areas[a] = area.index(a.to_s) ? true : false
      end
    else
      AREA_KEYWORDS[area_category].keys.each do |a|
        option_areas[a] = true
      end
    end

    option_sites = {}
    if cookies[:s] then
      site = cookies[:s]
      SITE_NAME.keys.each do |s, n|
        option_sites[s] = site.index(s.to_s) ? true : false
      end
    else
      SITE_NAME.keys.each do |s, n|
        option_sites[s] = true
      end
    end

    today = Date.today
    start_day = today
    end_day   = today + (MAX_MONTHS - 1).month

    area_list = get_area_list(area_category)
    area_name = get_area_name(area_category)

    calendar = {}
    updated = {}
    [TYPE_ATND, TYPE_ZUSAAR, TYPE_CONNPASS, TYPE_DOORKEEPER].each do |type|
      next if not option_sites[type]

      updated[type], events = get_events(type, area_category, start_day, end_day)

      events = filter_events(
        events,
        option_areas,
        @option_count,
        @option_limit,
        @option_full,
        NG_OWNER_ID[type],
        AREA_KEYWORDS[area_category],
        (area_category != AREA_KANTO)
      )

      events.each do |e|
        calendar[e[:date]] = [] if not calendar[e[:date]]
        calendar[e[:date]].push(e)
      end
    end

    @site_name = SITE_NAME
    @area_name = area_name
    @area_category = area_category
    @today = today
    @start_day = start_day
    @end_day = end_day
    @calendar = calendar
    @updated = updated

    @option_areas = option_areas
    @option_sites = option_sites

    @area_categories = AREA_CATEGORIES;
    @icons = {
      TYPE_ATND       => 'atnd.ico',
      TYPE_ZUSAAR     => 'zusaar.ico',
      TYPE_CONNPASS   => 'connpass.ico',
      TYPE_DOORKEEPER => 'doorkeeper.ico',
    }
  end

  def cache_read(key)
    cache_data = Rails.cache.read(key)
    if cache_data then
      return cache_data[:updated], cache_data[:data]
    else
      return nil, nil
    end
  end

  def cache_write(key, data)
    return Rails.cache.write(key, {:updated => Time.now.to_s, :data => data}, :expires_in => 60.minutes)
  end

  def filter_events(events, target_areas, min_count, min_limit, except_full, ng_owner_id, area_keywords, not_tokyo = false)
    results = []

    events.each do |e|

      tokyo = '東京'
      if not_tokyo &&  /^#{tokyo}/ =~ e[:address] then
        next
      end

      e[:area] = get_area(e[:address], area_keywords)

      if not e[:area] then
        next
      end

      if not target_areas[e[:area]] then
        next
      end

      if e[:count] < min_count then
        next
      end

      if min_limit > 0 then
        if not e[:limit] then
          next
        end
        if e[:limit] < min_limit then
          next
        end
      end

      if except_full && e[:count] >= e[:limit] then
        next
      end

      if ng_owner_id[e[:owner_id]] == true then
        next
      end

      results.push e
    end

    return results
  end

  def get_cache_key(type, area_category)
    cache_key = nil

    case type
    when TYPE_ATND
      cache_key = 'atnd_' + area_category.to_s
    when TYPE_ZUSAAR
      cache_key = 'zussaar'
    when TYPE_CONNPASS
      cache_key = 'connpass_' + area_category.to_s
    when TYPE_DOORKEEPER
      cache_key = 'doorkeeper'
    end

    return cache_key
  end

  def get_events(type, area_category, start_day, end_day, check_expire = false)
    area_list = nil
    if area_category then
      area_list = get_area_list(area_category)
    end
    cache_key = get_cache_key(type, area_category)

    clear_flag = nil

    updated, events = cache_read(cache_key)
    if events.nil? || check_expire && Time.parse(updated).to_i + EXPIRE_SEC < Time.now.to_i then
      events = get_events_from_site(type, start_day, end_day, area_list)

      cache_write(cache_key, events)
      clear_flag = true
    end

    return updated, events, clear_flag
  end

  def get_events_from_site(type, start_day, end_day, area_list)
    events = nil

    case type
    when TYPE_ATND
      events = get_events_from_atnd(start_day, end_day, area_list)
    when TYPE_ZUSAAR
      events = get_events_from_zusaar(start_day, end_day)
    when TYPE_CONNPASS
      events = get_events_from_connpass(start_day, end_day, area_list)
    when TYPE_DOORKEEPER
      events = get_events_from_doorkeeper(start_day, end_day)
    end

    return events
  end

  def get_events_from_atnd(start_day, end_day, area_list)
    return get_events_from_common(
      'http://api.atnd.org/events/',
      'http://atnd.org/events/',
      TYPE_ATND, start_day, end_day, area_list
    )
  end

  def get_events_from_zusaar(start_day, end_day)
    return get_events_from_common(
      'http://www.zusaar.com/api/event/',
      'http://www.zusaar.com/event/',
      TYPE_ZUSAAR, start_day, end_day, nil, :event
    )
  end

  def get_events_from_connpass(start_day, end_day, area_list)
    return get_events_from_common(
      'http://connpass.com/api/v1/event/',
      'http://connpass.com/event/',
      TYPE_CONNPASS, start_day, end_day, area_list
    )
  end

  def get_events_from_doorkeeper(start_day, end_day)
    events = []
    doorkeeper_max = 500

    options = {:since => start_day, :until => end_day, :page => 1}
    while events.size < doorkeeper_max do 

      c = 0
      begin
        json = get_json('http://api.doorkeeper.jp/events', options)
        json.each do |event_array|
          e = event_array[:event]
          event = {
            :type   => TYPE_DOORKEEPER,
            :date   => Time.parse(e[:starts_at]).strftime('%Y-%m-%d'),
            :title  => e[:title],
            :url    => e[:public_url],
            :limit  => e[:ticket_limit],
            :count  => e[:participants] + e[:waitlisted],
            :start  => Time.parse(e[:starts_at]).in_time_zone('Asia/Tokyo'),
            :end    => (e[:ends_at]) ? Time.parse(e[:ends_at]).in_time_zone('Asia/Tokyo') : nil,
            :address  => e[:address],
            :owner_id => e[:group][:id],
          }
          events.push(event)
          c += 1
        end

      rescue => e
        @error_msg.push 'doorkeeperのイベント情報の取得に失敗しました（' + e.message + '）'
        return events
      end

      if c == 0 then
        return events
      end

      options[:page] += 1
    end

    return events
  end


  def get_events_from_common(url_api, url_event, type, start_day, end_day, area_list = nil, event_param = :events)
    limit = 100

    ym = []
    cday = start_day
    while cday <= end_day do
      ym.push(sprintf('%d%02d', cday.year, cday.month))
      cday = cday + 1.months
    end

    options = {
      :format => 'json',
      :ym => ym.join(','),
      :count => limit,
      :start => 1,
    }
    if area_list then
      options[:keyword_or] = area_list.join(',')
    end

    events = []
    flag = true
    while flag do
      begin
        json = get_json(url_api, options)
        json[event_param].each do |e|
          event = {
            :type   => type,
            :date   => Time.parse(e[:started_at]).strftime('%Y-%m-%d'),
            :title  => e[:title],
            :url    => url_event + e[:event_id].to_s,
            :limit  => e[:limit],
            :count  => e[:accepted] + e[:waiting],
            :start  => Time.parse(e[:started_at]),
            :end    => (e[:ended_at]) ? Time.parse(e[:ended_at]) : nil,
            :address  => e[:address],
            :owner_id => e[:owner_id],
          }
          events.push(event)
        end
      rescue => e
        @error_msg.push 'イベント情報の取得に失敗しました（' + e.message + '）'
        return events
      end

      flag = false if json[event_param].size < limit || events.size >= MAX_EVENTS
      options[:start] += limit
    end

    return events
  end


  def get_area(address, area_keywords)

    area_keywords.each do |area, area_keyword|
      keywords = area_keyword[:name]
      keywords.each do |k|
        if /^#{k}/ =~ address then
          return area
        end
      end
    end

    area_keywords.each do |area, area_keyword|
      keywords = area_keyword[:key]
      keywords.each do |k|
        if /#{k}/i =~ address then
          return area
        end
      end
    end

    return nil
  end

  def get_json(url, data = {})
    body = file_get_contents(url + '?' + http_build_query(data))
    return JSON.parse(body, {:symbolize_names => true})
  end

  def http_build_query(options)
    query_string = (options||{}).map{|k,v|
      URI.encode(k.to_s) + "=" + URI.encode(v.to_s)
    }.join("&")
    return query_string
  end

  def file_get_contents(url)
    open(url) do |uri|
      return uri.read
    end
  end

end
