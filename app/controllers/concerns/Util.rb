require "open-uri"

module Util

  #
  # URLを指定してJSONを取得
  #
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