require 'mechanize'
require "net/http"  
require "uri"  
require 'cgi'
 

class SpiderBase
  
  INSERT_BUFFER = 100
  INSERT_STMT = "INSERT INTO flats(url, address, city, region, region_code, postal_code, spider, external_id, latitude, longitude, created_at, updated_at, kind, contact_phone, price, rooms, area, active) VALUES "
  NULL_STR = "NULL"

  
  attr_accessor :kind

  
  def dump
    @processed_count = 0
    @repeated_buffer = []
    reset_insert_buffer
    
    @timestamp = DateTime.now
    @timestamp_db = ActiveRecord::Base.connection.quote(@timestamp.to_formatted_s(:db))
    @start_time = Time.now
    puts "Starting process at #{@start_time}"

    Flat.record_timestamps = false
    #puts "Locking tables"
    #Flat.keys_enabled false
    
    self.kind = Flat::KIND_RENT if not self.kind

    do_dump
    
    # insert remaining
    insert_flats
    
    puts "Activating and cleaning up..."
    Flat.after_dump_cleanup(self.class.name, @timestamp_db)
    #puts "Unlocking tables"
    #Flat.keys_enabled true
    
    time = compute_running_time @start_time
    puts "Process completed at #{@now}. Running time: #{time[:hours]} hours, #{time[:mins]} minutes and #{time[:secs]} seconds"
  end
  
  def compute_running_time(start)
    now = Time.now
    elapsed = now - start
    
    hours = round_to(elapsed / (60*60), 0)
    elapsed -= hours * 60 * 60
    hours = 0 if hours < 1
    
    mins = round_to(elapsed / 60, 0)
    elapsed -= mins * 60
    mins = 0 if mins < 1

    secs = round_to(elapsed, 1)
    
    return :hours => hours, :mins => mins, :secs => secs
  end
  
  def do_dump
    raise "Not implemented"
  end
  
  def get_mechanize
    @agent = @agent or WWW::Mechanize.new do |agent| 
      agent.user_agent = "Googlebot/2.1 (+http://www.googlebot.com/bot.html)"
    end
  end
  
  def push_flat(data)
    external_id = data[:external_id]
    @insert_sql << ", " if @count > 0
    @insert_sql << "(#{ActiveRecord::Base.connection.quote(data[:url])}, "
    @insert_sql <<  "#{ActiveRecord::Base.connection.quote(data[:address])}, "
    @insert_sql <<  "#{ActiveRecord::Base.connection.quote(data[:city])}, "
    @insert_sql <<  "#{ActiveRecord::Base.connection.quote(data[:region])}, "
    @insert_sql <<  "#{ActiveRecord::Base.connection.quote(data[:postal_code][0,2])}, "
    @insert_sql <<  "#{ActiveRecord::Base.connection.quote(data[:postal_code])}, "
    @insert_sql <<  "#{ActiveRecord::Base.connection.quote(self.class.name)}, "
    @insert_sql <<  "#{ActiveRecord::Base.connection.quote(external_id)}, "
    @insert_sql <<  "#{data[:latitude] or NULL_STR}, "
    @insert_sql <<  "#{data[:longitude] or NULL_STR}, "
    @insert_sql <<  "#{@timestamp_db}, "
    @insert_sql <<  "#{@timestamp_db}, "
    @insert_sql <<  "#{ActiveRecord::Base.connection.quote(self.kind)}, "
    @insert_sql <<  "#{ActiveRecord::Base.connection.quote(data[:contact_phone])}, "
    @insert_sql <<  "#{data[:price]}, "
    @insert_sql <<  "#{data[:rooms] or NULL_STR}, "
    @insert_sql <<  "#{data[:area]}, "    
    @insert_sql <<  "FALSE) "
    
    @repeated_buffer.insert(0, external_id)

    @count += 1
    insert_flats if @count == INSERT_BUFFER
  end
  
  def update_flat(flat, values)
    flat.external_id = values[:external_id]
    flat.price = values[:price]
    flat.updated_at = @timestamp
    flat.save
  end
  
  def normalize_chars(str)
    {
      /\302\240/ => " ",
      /\341/     => "á",
      /\303\241/ => "á",
      /\351/     => "é",
      /\303\251/ => "é",
      /\355/     => "í",
      /\303\255/ => "í",
      /\363/     => "ó",
      /\303\263/ => "ó",
      /\372/     => "ú",
      /\303\272/ => "ú",
      /\361/     => "ñ",
      /\303\261/ => "ñ",
      /\264/     => "´",
      /\302\264/ => "´",
      /\350/     => "è",
      /\303\250/ => "è",
      /\347/     => "ç",
      /\303\247/ => "ç",
    }.each_pair{|k,v| str.gsub!(k,v) } if str
    str
  end
  
  
  def insert_flats
    if @processed_count > 0
      puts "Inserting #{@processed_count}..."
      ActiveRecord::Base.connection.execute @insert_sql
      reset_insert_buffer
    end
  end
  
  def reset_insert_buffer
    @count = 0
    @insert_sql = INSERT_STMT.clone
    @repeated_buffer.clear
  end
  
  def get_existing_flat external_id
    pending_to_insert = @repeated_buffer.include? external_id
    if pending_to_insert
      insert_flats
    end
    Flat.find(:first, :conditions => ["spider=? and external_id=?", self.class.name, external_id])
  end

  def load_http(url_str)  
    url = URI.parse(url_str)  
    req = Net::HTTP::Get.new(url.path)  
    req.add_field("User-Agent", "Mozilla/5.0 (X11; U; Linux i686; es-ES; rv:1.9.0.11) Gecko/2009060308 Ubuntu/9.04 (jaunty) Firefox/3.0.11")  
    res = Net::HTTP.new(url.host, url.port).start{|http| http.request(req)}  
    res.body  
  end    
  
  def get_uri_param(uri, param)
    values = CGI::parse(URI.parse(uri).query)[param]
    (values.size > 0) ? values[0] : nil
  end
  
  def begin_processing
    @processed_count += 1
    elapsed = Time.now - @start_time
    rate = @processed_count / elapsed
    round_to(rate, 2)
  end
  
  def round_to(f, x)
    (f * 10**x).round.to_f / 10**x
  end
  
  
end
