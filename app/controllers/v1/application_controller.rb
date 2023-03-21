# frozen_string_literal: true

module V1
  class ApplicationController < ApplicationController
    include V1::ApiResponder
  end
end
