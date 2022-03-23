require_relative '../lib/authorizer'
require_relative '../lib/event_store'
require_relative '../lib/rule_engine'
require_relative '../model/account'
require_relative '../model/transaction'

describe Authorizer do
  let(:store) { EventStore.new }
  let(:events) { [] }
  let(:subject) { Authorizer.new(store, events) }

  context 'when calling process' do
    context 'when it sees an account event' do
      let(:account) { Account.new('activeCard' => true, 'availableLimit' => 100) }
      let(:account2) { Account.new('activeCard' => true, 'availableLimit' => 25) }

      it 'returns account successfully if no validation error' do
        events << account
        expect(subject.process).to eq([account])
      end

      it 'returns validation error when an account is already added' do
        events << account
        events << account2
        expect(subject.process[1].violations).to eq([Rule::ACCOUNT_ALREADY_INITIALIZED])
      end
    end

    context 'when it sees a transaction event' do
      let(:account) { Account.new('activeCard' => true, 'availableLimit' => 100) }
      let(:transaction) { Transaction.new('merchant' => 'walmart', 'amount' => 10, 'time' => '2019-02-13T10:00:00.000Z') }
      let(:transaction2) { Transaction.new('merchant' => 'target', 'amount' => 10, 'time' => '2019-02-13T10:01:00.000Z') }
      let(:transaction3) { Transaction.new('merchant' => 'amazon', 'amount' => 10, 'time' => '2019-02-13T10:01:30.000Z') }
      let(:transaction4) { Transaction.new('merchant' => 'costco', 'amount' => 10, 'time' => '2019-02-13T10:01:45.000Z') }

      it 'returns account with successful transaction process if no validation error' do
        events << account
        events << transaction
        expect(subject.process[1].available_limit).to eq(90)
      end

      it 'returns insufficient limit validation error if account balance is not enough' do
        account.available_limit = 0
        events << account
        events << transaction
        expect(subject.process[1].violations).to eq([Rule::INSUFFICIENT_LIMIT])
      end

      it 'returns card not active validation error if the card is not active' do
        account.active_card = false
        events << account
        events << transaction
        expect(subject.process[1].violations).to eq([Rule::CARD_NOT_ACTIVE])
      end

      it 'returns doubled transaction validation error if there are more than 2 of the same transaction within 2 minutes' do
        transaction.merchant = transaction2.merchant = transaction3.merchant
        events << account
        events << transaction
        events << transaction2
        events << transaction3
        expect(subject.process[3].violations).to eq([Rule::DOUBLED_TRANSACTION])
      end

      it 'returns high frequency validation error if more than 3 transactions on a 2 minute interval' do
        events << account
        events << transaction
        events << transaction2
        events << transaction3
        events << transaction4
        expect(subject.process[4].violations).to eq([Rule::HIGH_FREQUENCY_SMALL_INTERVAL])
      end
    end
  end
end