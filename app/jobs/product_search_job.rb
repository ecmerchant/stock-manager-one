class ProductSearchJob < ApplicationJob
  queue_as :product_search

  rescue_from(StandardError) do |e|
    Rails.logger.debug "[ActiveJob] [#{self.class}] [#{job_id}] #{e}"
  end

  def perform(query, user)
    Product.search(query, user)
  end
end
