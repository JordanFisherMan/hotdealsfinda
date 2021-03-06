class Deal < ApplicationRecord
  validates :deal_id, :image_url, :title, :price, :url, :expiry_date,
            :division, :rating, :sort_price, :country_code, presence: true
  validates :deal_id, uniqueness: true
  belongs_to :category, optional: true
end
