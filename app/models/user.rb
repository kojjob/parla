class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :posts, dependent: :nullify
  has_many :comments, dependent: :destroy
  has_many :notifications, foreign_key: :recipient_id, dependent: :destroy
  has_one_attached :avatar

  # Roles
  enum :role, { user: 0, editor: 1, admin: 2 }, default: :user

  # Validations
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, uniqueness: { case_sensitive: false }

  # Check if user is an admin
  def admin?
    role == "admin"
  end

  # Check if user is an editor or admin
  def editor_or_admin?
    editor? || admin?
  end
end
