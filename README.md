# Gentle

Client library for integrating with the [Quiet Logistics](http://quietlogistics.com) API

## Installation

Add this line to your application's Gemfile:

    gem 'gentle'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gentle

## Usage

Basic usage for Gentle goes as follows:


```ruby
require 'gentle'
require 'gentle/documents/request/shipment_order'

credentials = {
  access_key_id: 'AWS_ACCESS_KEY', secret_access_key: 'SECRET_ACCESS_KEY',
  client_id: 'QUIET CLIENT ID', business_unit: 'QUIET BUSINESS UNIT',
  warehouse: 'QUIET WAREHOUSE',
  buckets: {
    to: 'gentle-to-quiet',
    from: 'gentle-from-quiet'
  },
  queues: {
    to: 'http://queue.amazonaws/1234567890/gentle_to_quiet'
    from: 'http://queue.amazonaws/1234567890/gentle_from_quiet'
    inventory: 'http://queue.amazonaws/1234567890/gentle_inventory'
  }
}
client = Gentle::Client.new(credentials)
# Orders are expected to have similar attributes as Spree/Solidus::Shipment
document = Gentle::Documents::Request::ShipmentOrder.new(client: client, shipment: shipment)

blackboard = Gentle::Blackboard.new(client)
queue = Gentle::Queue.new(client)

message = blackboard.post(document)
queue.send(message)

response_message = queue.receive
response_document = blackboard.fetch(message)
process_document(response_document)
blackboard.remove(message)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
