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
       run Cluster
    end

  end
end

#
# apiVersion: v1
# clusters:
# - cluster:
#     certificate-authority: /path/to/ca.crt
#     server: https://192.168.99.100:8443
#   name: minikube
# contexts:
# - context:
#     cluster: minikube
#     user: minikube
#   name: minikube
# current-context: minikube
# kind: Config
# preferences: {}
# users:
# - name: minikube
#   user:
#     client-certificate: /path/to/apiserver.crt
#     client-key: /path/to/apiserver.key
