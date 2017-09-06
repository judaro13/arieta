module Apps

  class ClusterDeck < APIDeck
    IMAGES ={"MongoDB" => "mongo", "PostgreSQL" => "postgres", "Kafka" => "cloudtrackinc/kubernetes-kafka"}
    DBS_PORTS ={"MongoDB" => "27017", "PostgreSQL" => "5432"}

    def create_dbs(data)
      return unless data
      data.each do |db|
        pod_name = db.name
        image = IMAGES[db.technology]
        port = db.properties.port || DBS_PORTS[db.technology]
        version = db.version
        Kubernetes.new.deploy(pod_name, image, port, version)
      end
    end
  end

  Cluster = Syro.new(ClusterDeck) do
    post do
      if req.params.keys.include?("devices")
        data = JSON.parse File.read(req.params.devices.tempfile)
        create_dbs(data.databases)
      else
        res.text "missing cluster file parameters"
      end
    end

    get do
      res.text Kubernetes.new.info
    end
  end
end

#
# curl \
# -F "pmml=nombre" \
# -F "devices=@./test.json" \
# localhost:3000/v1/dm-cluster/


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
