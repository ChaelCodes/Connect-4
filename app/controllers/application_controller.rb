class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  def hello
    render html: "hey you. You can do this. I am text, on a page, that you put here. If you can do that, you can do anything."
  end
end
