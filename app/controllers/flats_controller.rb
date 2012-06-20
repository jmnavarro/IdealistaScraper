class FlatsController < ApplicationController
  
  def index
    ll = params[:ll]
    dis = params[:d].to_i
    kind = params[:k]
    all = params[:all]
    
    ind = 1
    data = []
    while ll
      s = ll.split(",")
      found = Flat.find_nearby(s[0].to_d, s[1].to_d, dis, kind)
      found = supress_repeated(found) unless all == "y" 
      data.concat(found)
      ll = params["ll#{ind}"]
      ind += 1
    end

    respond_to do |format|
      format.html do
        render :status => (data.size == 0 ? 404 : 200), 
               :content_type => "application/json", 
               :text => data.to_json
      end
    end
  end


  def supress_repeated data
    session_ids = session[:sent_ids]
    if session_ids
      #TODO use binary search in session_ids
      data.reject!{|d| session_ids.detect{|e| e == d.id}}
      session[:sent_ids] = session_ids.concat(data.collect{|e| e.id})
    else
      session[:sent_ids] = data.collect{|e| e.id}
    end
    #puts session[:sent_ids]
    data
  end
end
