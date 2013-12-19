require 'uri'

class Params
  def initialize(req, route_params = {})
    @params = route_params
    parse_www_encoded_form(req.query_string) if req.query_string
    parse_www_encoded_form(req.body) if req.body
  end

  def [](key)
    @params[key]
  end

  def to_s
    @params.to_s
  end

  private
  def parse_www_encoded_form(www_encoded_form)
    array_of_params = URI.decode_www_form(www_encoded_form)
    
    array_of_params.each do |key_value_pair|
      key_hash = parse_key(*key_value_pair)
      @params.merge!(key_hash){ |k,a,b| a.merge(b) }
    end
  end

  def parse_key(key, value)
    new_hash = {}
    nested_hash = new_hash
    
    keys = key.split(/\]\[|\[|\]/)
    until keys.empty?  
      first_key = keys.shift
      
      unless keys.empty?
        new_hash[first_key] = {}
      else
        new_hash[first_key] = value
      end
      new_hash = new_hash[first_key]
    end
    nested_hash
  end
end
