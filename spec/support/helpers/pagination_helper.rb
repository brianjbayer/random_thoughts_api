# frozen_string_literal: true

module PaginationHelper
  def path_with_optional_page(path_helper_callback, page: false)
    page ? path_helper_callback.call({ page: }) : path_helper_callback.call
  end

  # NOTE: These uses APIHelper
  def data_body
    json_body['data']
  end

  def metadata_body
    json_body['meta']
  end
end
