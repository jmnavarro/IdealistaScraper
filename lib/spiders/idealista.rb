require 'lib/spiders/spider_base'
require 'hpricot'

# llamada de ejemplo
# Idealista.new.dump 

class Idealista < SpiderBase
  
  ROOT_URI = "http://www.idealista.com/pagina/portada?opidiom=cidioma&localeRef=es"
  FORM_SEARCH = "frmBusqueda"
  BASE_URL = "http://www.idealista.com/pagina/"

  
  def do_dump
    root_page = get_mechanize.get(ROOT_URI)
    #dump_flats(root_page, "28-XXX-XX-XXX-XX-XXX")
    dump_flats(root_page, "37-XXX-XX-XXX-XX-XXX")

    dump_cities(root_page).each do |city_code|
      if not city_code.starts_with? "53-"
        puts city_code
        dump_flats(root_page, city_code)
      end
    end
  end
  
  
  def kind_as_operacion
    case kind 
      when Flat::KIND_RENT then "A"
      when Flat::KIND_SALE then "V"
      else "A"
    end
  end

  def dump_flats(root_page, city_code)
    form = root_page.forms.detect{|e| e.name == FORM_SEARCH}
    form["operacion"] = kind_as_operacion
    form["tipoinmueble"] = "V"
    form["ubicacion"] = city_code
    search_result = form.submit

    link = search_result.links.detect{|e| e and e.href and e.href.starts_with? "./especificas?op=mostrar_pref&ubicacion="}
    if link
      search_result = link.click

      link = search_result.links.detect{|e| e.href.starts_with? "./buscar?zona-"}

      while link
        search_result = link.click
        dump_flat_page(search_result)
        link = search_result.links.detect{|e| e.to_s == "siguiente »"}
      end
    end

  end
  
  def dump_flat_page(search_result)
    flats = search_result.links.select do |e|
      e.href and e.href.index("?codigoinmueble=") and e.href.index("./inmueble") and 
        !e.href.index("secc_inm=fotos") and !e.href.index("&secc_inm=tour")
    end
    
    flats.each do |e|
      external_id = extract_external_id(e.href)
      fps = begin_processing
      existing_flat = get_existing_flat(external_id)
      price = extract_price(search_result, external_id)
      if existing_flat
        puts "(#{fps} fps) [#{external_id}] Update #{e.href}"
        update_flat(existing_flat, :external_id => external_id, :price => price)
      else 
        puts "(#{fps} fps) [#{external_id}] Add #{e.href}"
        data = get_flat_details(search_result, e, external_id)
        if data
          data[:price] = price
          push_flat data
        end
      end
    end
  end
  
  def extract_price(list, external_id)
    txt = list.parser.css("tr#tr_#{external_id}").first.text
    txt.split(/\n|\r|\t/).detect{|e| e.ends_with? "eur"}.gsub(/[^\d*]/, "")
  end
  
  def get_url(url)
    "#{BASE_URL}#{url[2..-1]}"
  end
  
  def get_flat_details(search_result, link, external_id)
    details_page = link.click
    ret = {}
    ret[:url] = details_page.uri.to_s

    doc = Hpricot details_page.body
    
    addr = normalize_chars(extract_address(doc))
    if addr
      ret[:address] = addr
      extract_place(doc, addr, ret)
      ret[:latitude], ret[:longitude] = extract_location(doc)
      ret[:external_id] = external_id
      ret[:contact_phone] = extract_contact_phone(doc)
      ret[:rooms] = extract_rooms(search_result, external_id)
      ret[:area] = extract_area(doc)
    else
      ret = nil
    end
    return ret
  end
  
  def extract_rooms(search_result, external_id)
    txt = search_result.parser.css("tr#tr_#{external_id}").first.text
    txt = txt.split(/\n|\r|\t/).detect{|e| e.ends_with? "dorm"}.gsub(/[^\d*]/, "")
    txt = nil if txt.size == 0
    txt
  end

  def extract_area(doc)
    doc.search("div#characteristics").first.to_plain_text.split(", ").detect{|e| e.ends_with? "m\262"}.gsub(/[^\d*]/, "")    
  end
  
  def extract_contact_phone(doc)
    # buscar por coincidencia de patrón
    #http://www.idealista./spiderscom/pagina/inmueble?codigoinmueble=VC0000002170362&numInm=1&edd=list
    found = doc.search("span.sidenote").select do |e| 
      e and e.to_plain_text.match(/hora|mañanas|ma\361anas|tardes|noches|comercial/)
    end
    if found.size > 0
      found.first.parent.to_plain_text.gsub(/[^\d*]/, "")
    else
      #buscar por longitud de cadena numérica
      #http://www.idealista.com/pagina/inmueble?codigoinmueble=VP0000002493500&numInm=81&edd=list
      found = doc.search("div.infoblock").inject(Array.new) do |result,e|
        result + process_children(result, e.children)
      end.uniq
      found = found.select do |e| 
        (e.size == 9 or (e.size > 9 and e.size < 14 and e[0,1] == "00" and e[2,3] != "000"))
      end
      if found.size > 0
        ret = found.detect{|e| e.size == 9}
        if not ret
          ret = found.first
        end
        ret
      else
        puts "     Can't find contact phone"
        nil
      end
    end
  end
  
  def process_children(result, children)
    children.each do |c|
      txt = c.to_plain_text.strip
      if c.respond_to?(:children) and c.children and c.children.size > 0
        result = process_children(result, c.children)
      else
        txt.gsub!(/[^\d*]/, "")
        result << txt if txt.size > 0 
      end
    end
    return result
  end
  
  def extract_external_id(uri)
    get_uri_param(uri, "codigoinmueble")
  end
  
  def extract_address(doc)
    ret = doc.at("#titulodetalle")
    if ret
      fulladdr = ret.to_plain_text
      ret = fulladdr[fulladdr.index(" en ")+4 .. fulladdr.length].strip.split(" ").join(" ")
    end
    return ret
  end
  
  def extract_place(doc, addr, data)
    # buscar por código postal
    full_line = doc.search("div.infoblock").collect do |e| 
      elems = e.search("li").concat(e.search("h3"))
      elems.collect do |e|
        s = e.to_plain_text
        if /^\d{5}\s{1}(\S*)/.match(s)
          s
        end
      end
    end.flatten.reject{|e| e.nil?}[0]
    
    if not full_line
      # bucar debajo de dirección
      list = doc.search("strong").select{|e| e and normalize_chars(e.to_plain_text) == addr}
      if list.size > 0
        sib_child = list.first.parent.next_sibling.children
        if sib_child.size > 0 
          full_line = sib_child[0].to_plain_text
        end
      end
    end
    
    if full_line
      parts = full_line.split(" ")
      data[:postal_code] = parts[0]
      full_region = parts[1..-1].join(" ")
      # manage "alicante / alacant, alicante"
      full_region = full_region.strip.split(", ").collect{|e| e.split(" / ")[0]}.uniq.join(", ")
      # manage "pamplona/iruña, navarra"
      parts = full_region.split(", ")
      if parts[0].index "/"
        parts[0] = parts[0].split("/")[0]
        full_region = "#{parts[0]}, #{parts[1]}"
      end
      # manage "coruña, a, la coruña"
      parts = full_region.split(", ")
      if (parts.size == 3)
        full_region = "#{parts[1]} #{parts[0]}, #{parts[2]}"
      end
      # separate city and region
      parts = normalize_chars(full_region).split(", ")
      data[:city] = parts[0]
      data[:region] = parts[(parts.size == 1) ? 0 : 1]
    else
      puts "     Can't find place"
    end
  end
  
  def extract_location(doc)
    link = doc.search(".linkout").detect{|e| e.html == "negocios en la zona"}
    if link
      url = link.get_attribute("href")
      # ./redir?origen=268&l=avenida unicef, 6&codigoinmueble=VW0000002363609&coordX=38.351487161241636&coordY=-.5032492287609087
      begin_idx = url.index("coordX=")
      end_idx = url.index("&", begin_idx)
      end_idx = url.length + 1 if not end_idx
      longitude = url[(begin_idx + "coordX".length + 1) .. (end_idx - 1)].to_d
      
      begin_idx = url.index("coordY=")
      end_idx = url.index("&", begin_idx)
      end_idx = url.length + 1 if not end_idx
      latitude = url[(begin_idx + "coordY".length + 1) .. (end_idx - 1)].to_d
      
      return longitude, latitude
    else
      puts "     Can't find location"
      return nil, nil
    end
  end
  
  def dump_cities(root_page)
    form = root_page.forms.detect{|e| e.name == FORM_SEARCH}
    list = form.fields.detect{|e| e.name == "ubicacion"}
    list.options.collect{|e| e.value}
  end
  
end
