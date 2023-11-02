class Url < ApplicationRecord
  validates :short_url, uniqueness: true
  validates :original_url, presence: true, format: { with: URI.regexp }

  def generate_short_url
    self.short_url = SecureRandom.hex(4)
  end
end
