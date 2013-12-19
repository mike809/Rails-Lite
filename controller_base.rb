require 'debugger'
require 'erb'
require_relative 'params'
require_relative 'session'

class ControllerBase
  attr_reader :params

  # setup the controller
  def initialize(req, res, route_params = {})
    @params = Params.new(req, route_params)
    @req = req
    @res = res
    @rendered_or_redirected = false
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(content, type)
    raise "Can't render or redirect twice." if already_rendered?
    @rendered_or_redirected = true
    @res.body = content
    @res.content_type = type
    session.store_session(@res)
  end

  # helper method to alias @already_rendered
  def already_rendered?
    @rendered_or_redirected
  end

  # set the response status code and header
  def redirect_to(url)
    raise "Can't render or redirect twice." if already_rendered?
    @rendered_or_redirected = true
    @res.set_redirect(WEBrick::HTTPStatus::TemporaryRedirect ,url)
    session.store_session(@res)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    content = File.read(
    "views/#{self.class.to_s.underscore}/#{template_name}.html.erb"
    )
    render_content(ERB.new(content).result(binding), 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name.to_sym)
    render name unless already_rendered?
  end
end
