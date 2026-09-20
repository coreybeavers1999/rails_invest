class Stocks::CeoEmploymentLog < ApplicationRecord
  belongs_to :ceo
  belongs_to :company

  enum :departure_status, {
    quit: "quit",
    fired: "fired",
    retired: "retired"
  }, validate: { allow_nil: true }
end
