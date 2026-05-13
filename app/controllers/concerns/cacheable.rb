module Cacheable
  extend ActiveSupport::Concern

  private

  def cache_key_for(resource, *parts)
    [ resource, *parts, "v1" ].join(":")
  end
end
