class Flat < ActiveRecord::Base
  
  KIND_RENT = "FR"
  KIND_SALE = "FS"
  
  def self.find_nearby(current_lat, current_lon, max_distance, kind)
    kind_condition = kind ? "AND kind = #{kind}" : ""
    
    sql = "SELECT f.id, f.city, f.address, f.url, f.latitude, f.longitude, 
                  f.city, f.kind, f.contact_phone, f.price, f.rooms, f.area, 
                  f.region, f.postal_code,
                  ROUND(ASIN(SQRT(POWER(SIN((#{current_lat} - abs(f.latitude)) * pi()/180 / 2), 2) + 
                  COS(#{current_lat} * pi()/180 ) * 
                  COS(abs(f.latitude) * pi()/180) * 
                  POWER(SIN((#{current_lon} - f.longitude) * pi()/180 / 2), 2))) * 6367000 * 2) as distance
           FROM flats AS f
           WHERE f.active = TRUE #{kind_condition}
           HAVING distance <= #{max_distance}
           ORDER BY distance"
    find_by_sql sql
  end
  
  def self.after_dump_cleanup(spider, ts)
    #TODO make transactional and isolated: time between activate and remove exposes inconsistent data

    # active just inserted
    activate_new(spider, ts)
    # remove old
    remove_previous(spider, ts)
  end
  
  def self.remove_previous(spider, ts)
    sql = "UPDATE flats 
           SET active = FALSE
           WHERE active = TRUE
             AND spider = #{ActiveRecord::Base.connection.quote(spider)}
             AND created_at < #{ts}"
    ActiveRecord::Base.connection.delete(sql)    
  end

  def self.activate_new(spider, ts)
    sql = "UPDATE flats 
           SET active = TRUE
           WHERE active = FALSE
             AND spider = #{ActiveRecord::Base.connection.quote(spider)}
             AND created_at = #{ActiveRecord::Base.connection.quote(ts)}"
    ActiveRecord::Base.connection.update(sql)    
  end
  
  def self.keys_enabled(enabled)
    if not enabled
      ActiveRecord::Base.connection.execute "LOCK TABLES flats WRITE"
    end
    ActiveRecord::Base.connection.execute "ALTER TABLE flats #{enabled ? "ENABLE" : "DISABLE"} KEYS"
    if enabled
      ActiveRecord::Base.connection.execute "UNLOCK TABLES"
    end
  end
    
end
