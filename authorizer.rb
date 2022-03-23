#!/usr/bin/env ruby

require_relative 'lib/authorizer'
require_relative 'lib/event_store'
require_relative 'lib/event_source'
require_relative 'lib/event_writer'

event_store = EventStore.new
input_events = EventSource.read_events
output_events = Authorizer.new(event_store, input_events).process
EventWriter.write(output_events)