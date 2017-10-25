class Kubernetes

  KAFKA = Kafka.new(
    seed_brokers: "localhost:9092",
    client_id: "simple-consumer"
  )

  def kubectl_run(command)
    sent_to_kafka( `kubectl #{command} 2>&1`)
  end

  def info
    `kubectl config view`
  end

  def get_deployments
    `kubectl get deployments`
  end

  def get_pods
    `kubectl get pods`
  end

  def deploy(pod_name, image_name, port="8080", version=nil, type=nil)
    port = "8080" if port.empty?
    kubectl_run("run #{pod_name} --image=#{image_name}#{version ? ":"+version : ""} --port=#{port}")
    if $?.success?
      kubectl_run("expose deployment #{pod_name} #{type ? "--type=#{type}" : ""} --port #{port}")
      if $?.success?
        Thread.start {stream_pod(pod_name)}
      end
    end
  end

  def deploy_limited(pod_name, image_name, port="8080", version=nil, type=nil, restrictions)
    port = "8080" if port.empty?
    data = File.read "src/lib/memory_limit.yml"
    data.gsub!("POD_NAME", pod_name)
    data.gsub!("POD_IMAGE", version ? "#{image_name}:#{version}" : image_name)
    data.gsub!("MEMORY_LIMIT", restrictions.memory_limit)
    data.gsub!("CPU_LIMIT", restrictions.cpu_limit)
    File.write("/tmp/temp_pod_confg.yml", data)
    kubectl_run("create -f /tmp/temp_pod_confg.yml")
    if $?.success?
      kubectl_run("expose deployment #{pod_name} #{type ? "--type=#{type}" : ""} --port #{port}")
      if $?.success?
        Thread.start {stream_pod(pod_name)}
      end
    end
    File.delete("/tmp/temp_pod_confg.yml") if File.exist?("/tmp/temp_pod_confg.yml")
  end

  def delete_service(pod_name)
    output = `kubectl delete pod,service,deployment  #{pod_name} 2>&1`
    sent_to_kafka(output)
    output
  end

  def services
    `kubectl get services`
  end

  def describe_pod(pod_name)
    `kubectl describe pods #{pod_name} `
  end

  def service_logs(pod_name)
    pod = pod_id(pod_name)
    response = kubectl_run("logs #{pod}")

  end

  def pod_status(pod_name)
    `kubectl get pod |grep #{pod_name} | awk '{print $3}'`    
  end

  def service_access_url(pod_name)
    port = kubectl_run("get services |grep #{pod_name} | awk '{print $4}'")
    port = port.split(':').last.gsub(/[^0-9]/, '')
    `minikube ip`+":"+port
  end

  def memory_use
    `kubectl describe nodes | grep -A 2 -e "^\\s*CPU Requests"`
  end

  def sent_to_kafka( message, topic="arieta")
    message.gsub!("\"", "'")
    KAFKA.deliver_message("{\"#{Time.now }\": \"#{message}\"}", topic: topic)
  end

  def pod_id(pod_name)
    `kubectl get pods |grep #{pod_name} | awk '{print $1}'`
  end


  def stream_pod(pod_name)
    # `kafka/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic #{pod_name}`
    pod = pod_id(pod_name)
    IO.popen("kubectl logs -f #{pod}") do |io|
      while (line = io.gets) do
        sent_to_kafka("{\"#{pod_name}\": \"#{line}\"}")
      end
    end
  end

end
