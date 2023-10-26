class Url < ApplicationRecord
  validates :short_url, uniqueness: true
  def self.find_by_short_url(short_url)
    find_by(short_url: short_url)
  end
end
