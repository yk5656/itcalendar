require "open-uri"
require "time"
require "active_support"

include Event
include Cache
include Util

class SampleController < ApplicationController

  def index
    calendar(AREA_KANTO)
  end
  def hokkaido_tohoku
    calendar(AREA_HOKKAIDO_TOHOKU)
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


  private

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
      AREA_CATEGORIES[area_category][:list].keys.each do |a|
        option_areas[a] = area.index(a.to_s) ? true : false
      end
    else
      AREA_CATEGORIES[area_category][:list].keys.each do |a|
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
    end_day   = today + MAX_MONTHS.month - 2.week

    calendar = {}
    updated = {}
    [TYPE_ATND, TYPE_ZUSAAR, TYPE_CONNPASS, TYPE_DOORKEEPER].each do |type|
      next if not option_sites[type]

      updated[type], classified_events = cache_read(SITE_NAME[type])
      if classified_events[area_category] then
        events = classified_events[area_category]
      else
        events = []
      end

      events = filter_events(
        events,
        option_areas,
        @option_count,
        @option_limit,
        @option_full,
        NG_OWNER_ID[type]
      )

      events.each do |e|
        calendar[e[:date]] = [] if not calendar[e[:date]]
        calendar[e[:date]].push(e)
      end
    end

    @site_name = SITE_NAME
    @area_name = AREA_CATEGORIES[area_category][:list]
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


  def filter_events(events, target_areas, min_count, min_limit, except_full, ng_owner_id)
    results = []

    events.each do |e|

      #if not e[:area] then
      #  next
      #end

      #if not target_areas[e[:area]] then
      #  next
      #end

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

      if ng_owner_id[e[:owner_id].to_i] == true then
        next
      end

      results.push e
    end

    return results
  end



end
