# frozen_string_literal: true

require 'money'
I18n.enforce_available_locales = false
Money.locale_backend = nil
Money.rounding_mode = BigDecimal::ROUND_HALF_UP

class CurrencyRenderer
  class << self
    def render_currency(value:)
      Money.new(value, 'GBP').format
    end
  end
end
