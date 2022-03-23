class Account
  attr_accessor :active_card, :available_limit, :violations

  def initialize(options)
    @active_card = options['activeCard']
    @available_limit = options['availableLimit']
    @violations = []
  end

  def to_hash
    { 
      activeCard: @active_card,
      availableLimit: @available_limit,
      violations: @violations
    }
  end
end
