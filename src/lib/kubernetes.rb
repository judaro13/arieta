class Kubernetes

  KAFKA = Kafka.new(
    seed_brokers: "localhost:9092",
    client_id: "simple-consumer"
  )

  def kubectl_run(command)
    sent_to_kafka( `kubectl #{command} 2>&1`)
  end

  def info
    kubectl_run('config view')
  end

  def get_deployments
    kubectl_run('get deployments')
  end

  def get_pods
    kubectl_run('get pod')
  end

  def deploy(pod_name, image_name, port="8080", version=nil, type=nil)
    binding.pry
    kubectl_run("run #{pod_name} --image=#{image_name}#{version ? ":"+version : ""} --port=#{port}")
    if $?.success?
      if $?.success?

        binding.pry
        Thread.start {stream_pod(pod_name)}
      end
    end
  end

  def events
    kubectl_run("get events")
  end

  def services
    kubectl_run("get services")
  end

  def service_logs(pod_name)
    pod = pod_id(pod_name)
    response = kubectl_run("logs #{pod}")

  end

  def service_access_url(pod_name)
    port = kubectl_run("get services |grep #{pod_name} | awk '{print $4}'")
    port = port.split(':').last.gsub(/[^0-9]/, '')
    `minikube ip`+":"+port
  end

  def memory_use
    `kubectl describe nodes | grep -A 2 -e "^\\s*CPU Requests"`
  end

  def sent_to_kafka( message, topic="kudesktop")
    KAFKA.deliver_message("#{Time.now } ===> #{message}", topic: topic)
  end

  def pod_id(pod_name)
    `kubectl get pods |grep #{pod_name} | awk '{print $1}'`
  end


  def stream_pod(pod_name)
    `kafka/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic #{pod_name}`
    pod = pod_id(pod_name)
    IO.popen("kubectl logs -f #{pod}") do |io|
      while (line = io.gets) do
        sent_to_kafka(line, pod_name)
      end
    end
  end

end
