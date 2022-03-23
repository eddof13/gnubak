require 'json'
require_relative '../model/account'
require_relative '../model/transaction'

class EventSource
  def self.read_events
    self.new.read_events
  end

  def read_events
    ARGF.readlines.map {|line| parse_event(line) }
  rescue
    raise "Unable to parse input"
  end

  private

  def parse_event(line)
    line = JSON.parse(line)
    key = line.keys.first
    Object::const_get(key.capitalize).new(line[key])
  end
end
