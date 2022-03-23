module Rule
  ACCOUNT_ALREADY_INITIALIZED = 'account-already-initialized'
  INSUFFICIENT_LIMIT = 'insufficient-limit'
  CARD_NOT_ACTIVE = 'card-not-active'
  HIGH_FREQUENCY_SMALL_INTERVAL = 'high-frequency-small-interval'
  DOUBLED_TRANSACTION = 'doubled-transaction'
end

class RuleEngine
  def self.check_account(account, store)
    violations = []
    if store.get('account') != nil
      violations << Rule::ACCOUNT_ALREADY_INITIALIZED
    end
    violations
  end

  def self.check_transaction(transaction, store)
    account = store.get('account')
    transactions = store.get('transactions')
    violations = []

    if transaction.amount > account.available_limit
      violations << Rule::INSUFFICIENT_LIMIT
    end

    if account.active_card == false
      violations << Rule::CARD_NOT_ACTIVE
    end

    if transactions.select {|t| Transaction.match?(t, transaction) }.length > 1
      violations << Rule::DOUBLED_TRANSACTION
    end

    if transactions.select {|t| (transaction.time - t.time) < 180 }.length > 2
      violations << Rule::HIGH_FREQUENCY_SMALL_INTERVAL
    end

    violations
  end
end
