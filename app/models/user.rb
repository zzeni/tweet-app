class User < ApplicationRecord
  has_many :tweets, dependent: :destroy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_attached_file :avatar,
                    styles: { medium: "300x300#", thumb: "100x100#" },
                    default_url: "/images/:style/missing.png"
end
