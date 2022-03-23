require_relative 'rule_engine'

class Authorizer
  def initialize(store, events)
    @store = store
    @events = events

    @store.set('account', nil) unless @store.key?('account')
    @store.set('transactions', []) unless @store.key?('transactions')
  end

  def process
    @events.map {|event| process_event(event) }
  end

  private

  def process_event(event)
    case event
    when Account
      handle_account(event)
    when Transaction
      handle_transaction(event)
    end
  end

  def handle_account(account)
    violations = RuleEngine.check_account(account, @store)
    if violations.length > 0
      account.violations = violations
    else
      @store.set('account', account)
    end
    account
  end

  def handle_transaction(transaction)
    violations = RuleEngine.check_transaction(transaction, @store)

    if violations.length > 0
      account = @store.get('account').dup
      account.violations = violations
    else
      account = @store.get('account').dup
      account.available_limit -= transaction.amount
      @store.set('account', account)
    end

    transactions = @store.get('transactions')
    transactions << transaction
    @store.set('transactions', transactions)

    account
  end
end
