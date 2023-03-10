# frozen_string_literal: true

module PaginationHelper
  # NOTE: This uses APIHelper

  def data_body
    json_body['data']
  end

  def metadata_body
    json_body['meta']
  end
end
