module Apps

  class ClusterDeck < APIDeck
    def process_services(data)
      return unless data
      data.each do |dp|
        pod_name = dp.name
        image = dp.image
        port = dp["properties"]["port"] ? dp.properties.port : "8080"
        if dp["version"]
          version =  dp["version"] ? dp.version : nil
        end

        if dp["device_configuration"]
          Kubernetes.new.deploy_limited(pod_name, image, port , version, "", dp.device_configuration)
        else
          Kubernetes.new.deploy(pod_name, image, port)
          #, nil, "NodePort")
        end
      end
    end
  end

  Cluster = Syro.new(ClusterDeck) do
    post do
      if req.params.keys.include?("services")
        data = JSON.parse File.read(req.params.services.tempfile)
        process_services(data)
        res.text "done"
      else
        res.text "missing 'services' file parameters"
      end
    end

    get do
      res.text Kubernetes.new.info
    end


    on "memory_use" do
      get do
        res.text Kubernetes.new.memory_use
      end
    end


    on "services" do
      get do
        res.text Kubernetes.new.services
      end
    end

    on "pods" do
      get do
        res.text Kubernetes.new.get_pods
      end

      on :pod_name do
        delete do
          out = Kubernetes.new.delete_service(inbox[:pod_name])
          res.text out
        end

        get do
          out = Kubernetes.new.pod_status(inbox[:pod_name])
          res.text out
        end

        on "describe" do
          get do
            res.text Kubernetes.new.describe_pod(inbox[:pod_name])
          end
        end


      end
    end


  end
end

# #
# curl \
# -F "services=@./test.json" \
# localhost:3001/v1/


# curl \
# -F "name=nombre" \
# localhost:3000/v1/dm-cluster/
# get /  -> show info
# post /  -> create new cluster and vm
# get /name/  -> show cluster info
# post /name/  -> new vm
# get /name/namevm/ -> show info
# post /name/namevm/ -f pmml -> assign
# patch /name/namevm/ -f pmml -> edit pmml
# delete /name/namevm/ -> delete vm
