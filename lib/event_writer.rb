class EventWriter
  def self.write(events)
    events.each do |event|
      STDOUT.write(event.to_hash.to_s + "\n")
    end
  end
end
