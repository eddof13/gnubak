require 'time'

class Transaction
  attr_accessor :merchant, :amount, :time

  def self.match?(a, b)
    a.merchant == b.merchant && a.amount == b.amount && (b.time - a.time) < 120
  end

  def initialize(options)
    @merchant = options['merchant']
    @amount = options['amount']
    @time = Time.iso8601(options['time'])
  end
end
