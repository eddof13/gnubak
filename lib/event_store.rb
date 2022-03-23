class EventStore
  def initialize
    @store = {}
  end

  def set(key, value)
    @store[key] = value
  end

  def get(key)
    @store[key]
  end

  def key?(key)
    @store.key?(key)
  end
end
