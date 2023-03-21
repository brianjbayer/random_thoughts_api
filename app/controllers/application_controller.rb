class ApplicationController < ActionController::API
  include JwtAuthorizer
  include Error::ErrorHandler
end
