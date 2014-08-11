module Cache

  #
  # キャシュの読み込み
  #
  def cache_read(key)
    cache_data = Rails.cache.read(key)
    if cache_data then
      return cache_data[:updated], cache_data[:data]
    else
      return nil, nil
    end
  end

  #
  # キャッシュの書き込み
  #
  def cache_write(key, data)
    return Rails.cache.write(key, {:updated => Time.now.to_s, :data => data}, :expires_in => 7.days)
  end

end