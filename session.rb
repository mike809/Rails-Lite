require 'json'
require 'webrick'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    req.cookies.each do |cookie|
      next unless cookie.name == '_rails_lite_app'
      @session = JSON.parse(cookie.value)
      break
    end
    @session ||= {}
  end

  def [](key)
    @session[key]
  end

  def []=(key, val)
    @session[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    cookie = WEBrick::Cookie.new("_rails_lite_app", JSON.generate(@session))
    res.cookies << cookie
  end
end
