class Stocks::Ceo < ApplicationRecord
  belongs_to :company, optional: true
  has_many :ceo_employment_logs, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true
  validates :skill, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :controversial, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  scope :available, -> { where(company_id: nil) }

  before_validation :initialize_values

  # Statuses
  def retired?
    retired
  end

  def available?
    company_id.nil?
  end

  def employed?
    !available?
  end

  def status
    return "retired" if retired?
    return "available" if available?
    "employed"
  end

  private

  def initialize_values
    self.skill = SecureRandom.random_number(0..100)
    self.controversial = SecureRandom.random_number(0..100)
  end
end
