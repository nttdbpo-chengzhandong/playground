class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  def crash
    1/0
    render html: "hello, world!"
  end
end
