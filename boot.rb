require 'bundler'

# TODO conditionally load test group
Bundler.require :default, ENV.fetch("RACK_ENV", "test")

require_all 'config'

require_all 'src/lib'
require_all 'src/apps'

KAFKA = Kafka.new(
  seed_brokers: "localhost:9092",
  client_id: "simple-consumer"
)

module Apps
  Root = Syro.new(APIDeck) do

    on "v1" do
      on ("dm-cluster") { run Cluster }
    end

  end
end
