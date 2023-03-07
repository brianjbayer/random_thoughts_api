class ApplicationController < ActionController::API
  include ApiResponder
  include JwtAuthorizer
  include Error::ErrorHandler
end
