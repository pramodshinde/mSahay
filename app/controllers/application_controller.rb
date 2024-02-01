class ApplicationController < ActionController::Base
  after_action :allow_iframe

  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end
end
