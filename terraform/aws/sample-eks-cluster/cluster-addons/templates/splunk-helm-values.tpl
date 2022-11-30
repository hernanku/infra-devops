# Splunk Connect for Kubernetes is a umbraller chart for three charts
# * splunk-kubernetes-logging
# * splunk-kubernetes-objects
# * splunk-kubernetes-metrics

# Use global configurations for shared configurations between sub-charts.
# Supported global configurations:
# Values defined here are the default values.
global:
  logLevel: debug
  splunk:
    hec:
      # host is required and should be provided by user
      host: http-inputs-ocs.splunkcloud.com
      # port to HEC, optional, default 8088
      port: 443
      # token is required and should be provided by user
      token:  "${splunk_hec_token}"
      # protocol has two options: "http" and "https", default is "https"
      # For self signed certficate leave this field blank
      protocol: https
      # indexName tells which index to use, this is optional. If it's not present, will use "main".
      indexName: "${splunk_index}"
      # insecureSSL is a boolean, it indicates should it allow insecure SSL connection (when protocol is "https"). Default is false.
      # For a self signed certficate this value should be true
      insecureSSL: true
      # The PEM-format CA certificate for this client.
      # NOTE: The content of the certificate itself should be used here, not the file path.
      #       The certificate will be stored as a secret in kubernetes.
      clientCert:
      # The private key for this client.
      # NOTE: The content of the key itself should be used here, not the file path.
      #       The key will be stored as a secret in kubernetes.
      clientKey:
      # The PEM-format CA certificate file.
      # NOTE: The content of the file itself should be used here, not the file path.
      #       The file will be stored as a secret in kubernetes.
      # For self signed certficate leave this field blank
      caFile:
      # For object and metrics
      indexRouting: "${splunk_metric_index}"
  kubernetes:
    # The cluster name used to tag logs. Default is cluster_name
    clusterName: "${cluster_name}"
  prometheus_enabled: true
  monitoring_agent_enabled: true
  monitoring_agent_index_name: "${splunk_metric_index}"
  # deploy a ServiceMonitor object for usage of the PrometheusOperator
  serviceMonitor:
    enabled: false

    metricsPort: 24231
    interval: ""
    scrapeTimeout: "10s"

    additionalLabels: { }

## Enabling splunk-kubernetes-logging will install the `splunk-kubernetes-logging` chart to a kubernetes
## cluster to collect logs generated in the cluster to a Splunk indexer/indexer cluster.
splunk-kubernetes-logging:
  enabled: true
  # logLevel is to set log level of the Splunk log collector. Avaiable values are:
  # * trace
  # * debug
  # * info (default)
  # * warn
  # * error
  logLevel:

  # This is can be used to exclude verbose logs including various system and Helm/Tiller related logs.
  fluentd:
    # path of logfiles, default /var/log/containers/*.log
    path: /var/log/containers/*.log
    # paths of logfiles to exclude. object type is array as per fluentd specification:
    # https://docs.fluentd.org/input/tail#exclude_path
    exclude_path:
    #  - /var/log/containers/kube-svc-redirect*.log
    #  - /var/log/containers/tiller*.log
    #  - /var/log/containers/*_kube-system_*.log (to exclude `kube-system` namespace)

  # Configurations for container logs
  containers:
    # Path to root directory of container logs
    path: /var/log
    # Final volume destination of container log symlinks
    pathDest: /var/lib/docker/containers
    # Log format type, "json" or "cri"
    logFormatType: json
    # Specify the logFormat for "cri" logFormatType - provide time format
    # For example "%Y-%m-%dT%H:%M:%S.%N%:z" for openshift, "%Y-%m-%dT%H:%M:%S.%NZ" for IBM IKS 
    # Default for "cri": "%Y-%m-%dT%H:%M:%S.%N%:z"
    # For "json", the log format cannot be changed: "%Y-%m-%dT%H:%M:%S.%NZ"
    logFormat:
    # Specify the interval of refreshing the list of watch file.
    refreshInterval:

  # Enriches log record with kubernetes data
  k8sMetadata:
    # Pod labels to collect
    podLabels:
      - app
      - k8s-app
      - release
    watch: true
    cache_ttl: 3600

  sourcetypePrefix: "kube"
  
  rbac:
    # Specifies whether RBAC resources should be created.
    # This should be set to `false` if either:
    # a) RBAC is not enabled in the cluster, or
    # b) you want to create RBAC resources by yourself.
    create: true
    # If you are on OpenShift and you want to run the a privileged pod
    # you need to have a ClusterRoleBinding for the system:openshift:scc:privileged
    # ClusterRole. Set to `true` to create the ClusterRoleBinding resource
    # for the ServiceAccount.
    openshiftPrivilegedSccBinding: false

  serviceAccount:
    # Specifies whether a ServiceAccount should be created
    create: true
    # The name of the ServiceAccount to use.
    # If not set and create is true, a name is generated using the fullname template
    name: "${splunk_service_account}-log"

  podSecurityPolicy:
    # Specifies whether Pod Security Policy resources should be created.
    # This should be set to `false` if either:
    # a) Pod Security Policies is not enabled in the cluster, or
    # b) you want to create Pod Security Policy resources by yourself.
    create: false
    # Specifies whether AppArmor profile should be applied.
    # if set to true, this will add two annotations to PodSecurityPolicy:
    # apparmor.security.beta.kubernetes.io/allowedProfileNames: 'runtime/default'
    # apparmor.security.beta.kubernetes.io/defaultProfileName:  'runtime/default'
    # set to false if AppArmor is not available
    apparmor_security: true
    # apiGroup can be set to "extensions" for Kubernetes < 1.10.
    apiGroup: policy

  # Local splunk configurations
  splunk:
    # Configurations for HEC (HTTP Event Collector)
    hec:
      # host is required and should be provided by user
      host: http-inputs-ocs.splunkcloud.com
      # port to HEC, optional, default 8088
      port: 443
      # token is required and should be provided by user
      token: "${splunk_hec_token}"
      # protocol has two options: "http" and "https", default is "https"
      # For self signed certficate leave this field blank
      protocol: 
      # indexName tells which index to use, this is optional. If it's not present, will use "main".
      indexName: "${splunk_index}"
      # insecureSSL is a boolean, it indicates should it allow insecure SSL connection (when protocol is "https"). Default is false.
      # For a self signed certficate this value should be true
      insecureSSL: true
      # The PEM-format CA certificate for this client.
      # NOTE: The content of the certificate itself should be used here, not the file path.
      #       The certificate will be stored as a secret in kubernetes.
      clientCert:
      # The private key for this client.
      # NOTE: The content of the key itself should be used here, not the file path.
      #       The key will be stored as a secret in kubernetes.
      clientKey:
      # The PEM-format CA certificate file.
      # NOTE: The content of the file itself should be used here, not the file path.
      #       The file will be stored as a secret in kubernetes.
      caFile:
    # Configurations for Ingest API
    ingest_api:
      # serviceClientIdentifier is a string, the client identifier is used to make requests to the ingest API with authorization.
      serviceClientIdentifier:
      # serviceClientSecretKey is a string, the client identifier is used to make requests to the ingest API with authorization.
      serviceClientSecretKey:
      # tokenEndpoint is a string, it indicates which endpoint should be used to get the authorization token used to make requests to the ingest API.
      tokenEndpoint:
      # ingestAuthHost is a string, it indicates which url/hostname should be used to make token auth requests to the ingest API.
      ingestAuthHost:
      # ingestAPIHost is a string, it indicates which url/hostname should be used to make requests to the ingest API.
      ingestAPIHost:
      # tenant is a string, it indicates which tenant should be used to make requests to the ingest API.
      tenant:
      # eventsEndpoint is a string, it indicates which endpoint should be used to make requests to the ingest API.
      eventsEndpoint:
      # debugIngestAPI is a boolean, it indicates whether user wants to debug requests and responses to ingest API. Default is false.
      debugIngestAPI:

  # Create or use existing secret if name is empty default name is used
  secret:
    create: true
    name:

  # Directory where to read journald logs.
  journalLogPath: /run/log/journal

  # Set to true, to change the encoding of all strings to utf-8.
  #
  # By default fluentd uses ASCII-8BIT encoding. If you have 2-byte chars in your logs
  # you need to set the encoding to UTF-8 instead.
  #
  charEncodingUtf8: false

  # `logs` defines the source of logs, multiline support, and their sourcetypes.
  #
  # The scheme to define a log is:
  #
  # ```
  # <name>:
  #   from:
  #     <source>
  #   timestampExtraction:
  #     regexp: "<regexp_to_extract_timestamp_from_log>"
  #     format: "<format_of_the_timestamp>"
  #   multiline:
  #     firstline: "<regexp_to_detect_firstline_of_multiline>"
  #     flushInterval 5
  #   sourcetype: "<sourcetype_of_logs>"
  # ```
  #
  # = <source> =
  # It supports 3 kinds of sources: journald, file, and container.
  # For `journald` logs, `unit` is required for filtering using _SYSTEMD_UNIT, example:
  # ```
  # docker:
  #   from:
  #     journald:
  #       unit: docker.service
  # ```
  #
  # For `file` logs, `path` is required for specifying where is the log files. Log files are expected in `/var/log`, example:
  # ```
  # docker:
  #   from:
  #     file:
  #       path: /var/log/docker.log
  # ```
  #
  # For `container` logs, pod name is required. You can also provide the container name, if it's not provided, the name of this source will be used as the container name:
  # ```
  # kube-apiserver:
  #   from:
  #     pod: kube-apiserver
  #
  # etcd:
  #   from:
  #     pod: etcd-server
  #     container: etcd-container
  # ```
  #
  # = timestamp =
  # `timestampExtraction` defines how to extract timestamp from logs. This *only* works for `file` source.
  # To use `timestampExtraction` you need to define both:
  # - `regexp`: the Regular Expression used to find the timestamp from a log entry.
  #             The timestamp part must be in a `time` named group. E.g.
  #             (?<time>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})
  # - `format`: a format string defintes how to parse the timestamp, e.g. "%Y-%m-%d %H:%M:%S".
  #             More details can be find: http://ruby-doc.org/stdlib-2.5.0/libdoc/time/rdoc/Time.html#method-c-strptime
  #
  # = multiline =
  # `multiline` options provide basic multiline support. Two options:
  # - `firstline`: a Regular Expression used to detect the first line of a multiline log.
  # - `endline`: a Regular Expression used to detect the end line of a multiline log.
  # - `flushInterval`: The number of seconds after which the last received event log will be flushed, default value: 5s.
  #
  # = sourcetype =
  # sourcetype of each kind of log can be defined using the `sourcetype` field.
  # If `sourcetype` is not defined, `name` will be used.
  #
  # ---
  # Here we have some default timestampExtraction and multiline settings for kubernetes components.
  # So, usually you just need to redefine the source of those components if necessary.
  logs:
    docker:
      from:
        journald:
          unit: docker.service
      timestampExtraction:
        regexp: time="(?<time>\d{4}-\d{2}-\d{2}T[0-2]\d:[0-5]\d:[0-5]\d.\d{9}Z)"
        format: "%Y-%m-%dT%H:%M:%S.%NZ"
      sourcetype: kube:docker
    kubelet: &glog
      from:
        journald:
          unit: kubelet.service
      timestampExtraction:
        regexp: \w(?<time>[0-1]\d[0-3]\d [^\s]*)
        format: "%m%d %H:%M:%S.%N"
      multiline:
        firstline: /^\w[0-1]\d[0-3]\d/
      sourcetype: kube:kubelet
    etcd:
      from:
        pod: etcd-server
        container: etcd-container
      timestampExtraction:
        regexp: (?<time>\d{4}-\d{2}-\d{2} [0-2]\d:[0-5]\d:[0-5]\d\.\d{6})
        format: "%Y-%m-%d %H:%M:%S.%N"
    etcd-events:
      from:
        pod: etcd-server-events
        container: etcd-container
      timestampExtraction:
        regexp: (?<time>\d{4}-[0-1]\d-[0-3]\d [0-2]\d:[0-5]\d:[0-5]\d\.\d{6})
        format: "%Y-%m-%d %H:%M:%S.%N"
    kube-apiserver:
      <<: *glog
      from:
        pod: kube-apiserver
      sourcetype: kube:kube-apiserver
    kube-scheduler:
      <<: *glog
      from:
        pod: kube-scheduler
      sourcetype: kube:kube-scheduler
    kube-controller-manager:
      <<: *glog
      from:
        pod: kube-controller-manager
      sourcetype: kube:kube-controller-manager
    kube-proxy:
      <<: *glog
      from:
        pod: kube-proxy
      sourcetype: kube:kube-proxy
    kubedns:
      <<: *glog
      from:
        pod: kube-dns
      sourcetype: kube:kubedns
    dnsmasq:
      <<: *glog
      from:
        pod: kube-dns
      sourcetype: kube:dnsmasq
    dns-sidecar:
      <<: *glog
      from:
        pod: kube-dns
        container: sidecar
      sourcetype: kube:kubedns-sidecar
    dns-controller:
      <<: *glog
      from:
        pod: dns-controller
      sourcetype: kube:dns-controller
    kube-dns-autoscaler:
      <<: *glog
      from:
        pod: kube-dns-autoscaler
        container: autoscaler
      sourcetype: kube:kube-dns-autoscaler
    kube-audit:
      from:
        file:
          path: /var/log/kube-apiserver-audit.log
      timestampExtraction:
        format: "%Y-%m-%dT%H:%M:%SZ"
      sourcetype: kube:apiserver-audit

  # Defines which version of image to use, and how it should be pulled.
  image:
    # The domain of the registry to pull the image from
    registry: docker.io
    # The name of the image to pull
    name: splunk/fluentd-hec
    # The tag of the image to pull
    tag: 1.2.7
    # The policy that specifies when the user wants the images to be pulled
    pullPolicy: IfNotPresent
    # Indicates if the image should be pulled using authentication from a secret
    usePullSecret: false
    # The name of the pull secret to attach to the respective serviceaccount used to pull the image
    pullSecretName:

  # Environment variable for daemonset
  environmentVar:

  # Pod annotations for object pod
  podAnnotations:

  # Controls the resources used by the fluentd daemonset
  resources:
    limits:
     cpu: 200m
     memory: 500Mi
    requests:
      cpu: 100m
      memory: 200Mi

  # Controls the output buffer for the fluentd daemonset
  # Note that, for memory buffer, if `resources.limits.memory` is set,
  # the total buffer size should not bigger than the memory limit, it should also
  # consider the basic memory usage by fluentd itself.
  # All buffer parameters (except Argument) defined in
  # https://docs.fluentd.org/v1.0/articles/buffer-section#parameters
  # can be configured here.
  buffer:
    "@type": memory
    total_limit_size: 600m
    chunk_limit_size: 20m
    chunk_limit_records: 100000
    flush_interval: 5s
    flush_thread_count: 1
    overflow_action: block
    retry_max_times: 5
    retry_type: periodic

  # set to true to keep the structure created by docker or journald
  sendAllMetadata: false

  # This default tolerations allow the daemonset to be deployed on master nodes,
  # so that we can also collect logs from those nodes.
  tolerations:
    - key: node-role.kubernetes.io/master
      effect: NoSchedule

  # Defines which nodes should be selected to deploy the fluentd daemonset.
  nodeSelector:
    beta.kubernetes.io/os: linux

  # Defines node affinity to restrict pod deployment.
  affinity: {}

  # Extra volumes required by pod
  extraVolumes: []
  extraVolumeMounts: []

  # Defines priorityClassName to assign a priority class to pods.
  priorityClassName:

  # = Kubernetes Connection Configs =
  kubernetes:
    # The cluster name used to tag logs. Default is cluster_name
    clusterName: "${cluster_name}"
    # This flag specifies if the user wants to use a security context for creating the pods, which will be used to run privileged pods
    securityContext: false


  # List of key/value pairs for metadata purpse.
  # Can be used to define things such as cloud_account_id, cloud_account_region, etc.
  customMetadata:
  #  - name: "cloud_account_id"
  #    value: "1234567890"

  # List of annotation metadata you would like to enrich log data with
  customMetadataAnnotations:
  #  - name: custom_field
  #    annotaion: splunk.com/custom_field

  # `customFilters` defines the custom filters to be used.
  # This section can be used to define custom filters using plugins like https://github.com/splunk/fluent-plugin-jq
  # Its also possible to use other filters like https://www.fluentd.org/plugins#filter
  #
  # The scheme to define a custom filter is:
  #
  # ```
  # <name>:
  #   tag: <fluentd tag for the filter>
  #   type: <fluentd filter type>
  #   body: <definition of the fluentd filter>
  # ```
  #
  # = fluentd tag for the filter =
  # This is the fluentd tag for the record
  #
  # = fluentd filter type =
  # This is the fluentd filter that the user wants to use for record manipulation.
  #
  # = definition of the fluentd filter =
  # This defines the body/logic for using the filter for record manipulation.
  #
  # For example if you want to define a filter which sets cluster_name field to "my_awesome_cluster" you would the following filter
  # <filter tail.containers.**>
  #  @type jq_transformer
  #  jq '.record.cluster_name = "my_awesome_cluster" | .record'
  # </filter>
  # This can be defined in the customFilters section as follows:
  # ```
  # customFilters:
  #   NamespaceSourcetypeFilter:
  #     tag: tail.containers.**
  #     type: jq_transformer
  #     body: jq '.record.cluster_name = "my_awesome_cluster" | .record'
  # ```
  customFilters: {}

  # You can find more information on indexed fields here - https://dev.splunk.com/enterprise/docs/dataapps/httpeventcollector
  # The scheme to define an indexed field is:
  #
  # ```
  # ["field_1", "field_2"]
  # ```
  #
  # `indexFields` defines the fields from the fluentd record to be indexed.
  # You can find more information on indexed fields here - http://dev.splunk.com/view/event-collector/SP-CAAAFB6
  # The input is in the form of an array(comma separated list) of the values you want to use as indexed fields.
  #
  # For example if you want to define indexed fields for "field_1" and "field_2"
  # you will have to define an indexFields section as follows in values.yaml file.
  # ```
  # indexFields: ["field_1", "field_2"]
  # ```
  # WARNING: The fields being used here must be available inside the fluentd record.
  indexFields: []

## Enabling splunk-kubernetes-objects will install the `splunk-kubernetes-objects` chart to a kubernetes
## cluster to collect kubernetes objects in the cluster to a Splunk indexer/indexer cluster.
splunk-kubernetes-objects:
  enabled: true
  # logLevel is to set log level of the object collector. Avaiable values are:
  # * trace
  # * debug
  # * info (default)
  # * warn
  # * error
  logLevel:

  rbac:
    # Specifies whether RBAC resources should be created.
    # This should be set to `false` if either:
    # a) RBAC is not enabled in the cluster, or
    # b) you want to create RBAC resources by yourself.
    create: true

  serviceAccount:
    # Specifies whether a ServiceAccount should be created
    create: true
    # The name of the ServiceAccount to use.
    # If not set and create is true, a name is generated using the fullname template
    name: "${splunk_service_account}-objects"
    # This flag specifies if the user wants to use a secret for creating the serviceAccount,
    # which will be used to get the images from a private registry
    usePullSecrets: false

  podSecurityPolicy:
    # Specifies whether Pod Security Policy resources should be created.
    # This should be set to `false` if either:
    # a) Pod Security Policies is not enabled in the cluster, or
    # b) you want to create Pod Security Policy resources by yourself.
    create: false
    # Specifies whether AppArmor profile should be applied.
    # if set to true, this will add two annotations to PodSecurityPolicy:
    # apparmor.security.beta.kubernetes.io/allowedProfileNames: 'runtime/default'
    # apparmor.security.beta.kubernetes.io/defaultProfileName:  'runtime/default'
    # set to false if AppArmor is not available
    apparmor_security: true
    # apiGroup can be set to "extensions" for Kubernetes < 1.10.
    apiGroup: policy

  # Defines priorityClassName to assign a priority class to pods.
  priorityClassName:

  # = Kubernetes Connection Configs =
  kubernetes:
    # the URL for calling kubernetes API, by default it will be read from the environment variables
    url:
    # if insecureSSL is set to true, insecure HTTPS API call is allowed, default false
    insecureSSL: true
    # Path to the certificate file for this client.
    clientCert:
    # Path to the private key file for this client.
    clientKey:
    # Path to the CA file.
    caFile:
    # Path to the file contains the API token. By default it reads from the file "token" in the `secret_dir`.
    bearerTokenFile:
    # Path of the location where pod's service account's credentials are stored. Usually you don't need to care about this config, the default value should work in most cases.
    secretDir:
    # The cluster name used to tag cluster metrics from the aggregator. Default is cluster_name
    clusterName:

  # = Object Lists =
  # NOTE: at least one object must be provided.
  #
  # == Schema ==
  # ```
  # objects:
  #   <apiGroup>:
  #     <apiVersion>:
  #       - <objectDefinition>
  # ```
  #
  # Each `objectDefinition` has the following fields:
  # * mode:
  #     define in which way it collects this type of object, either "poll" or "watch".
  #     - "poll" mode will read all objects of this type use the list API at an interval.
  #     - "watch" mode will setup a long connection using the watch API to just get updates.
  # * name: [REQUIRED]
  #     name of the object, e.g. `pods`, `namespaces`.
  #     Note that for resource names that contains multiple words, like `daemonsets`,
  #     words need to be separated with `_`, so `daemonsets` becomes `daemon_sets`.
  # * namespace:
  #     only collects objects from the specified namespace, by default it's all namespaces
  # * labelSelector:
  #     select objects by label(s)
  # * fieldSelector:
  #     select objects by field(s)
  # * interval:
  #     the interval at which object is pulled, default 15 minutes.
  #     Only useful for "poll" mode.
  #
  # == Example ==
  # ```
  # objects:
  #   core:
  #     v1:
  #       - name: pods
  #         namespace: default
  #         mode: pull
  #         interval: 60m
  #       - name: events
  #         mode: watch
  #   apps:
  #     v1:
  #       - name: daemon_sets
  #         labelSelector: environment=production
  # ```
  objects:
    core:
      v1:
        - name: pods
        - name: namespaces
        - name: nodes
        - name: services
        - name: config_maps
        - name: persistent_volumes
        - name: service_accounts
        - name: persistent_volume_claims
        - name: resource_quotas
        - name: component_statuses
        - name: events
          mode: watch
    apps:
      v1:
        - name: deployments
        - name: daemon_sets
        - name: replica_sets
        - name: stateful_sets

  # = Checkpoint Configs =
  # defines the checkpoint file used for saving the resourceVersion of watched objects,
  # so that when the fluentd pod restarts, it will continue from where it stopped.
  # NOTE: since kubernetes has its own cache limit, if the fluentd pod has stopped for a long time,
  # it might not be able to start watch from the checkpoint.
  checkpointFile:
    # the name of the checkpoint file.
    name: kubernetes-objects.pos
    # volume is a kubernetes volume configuration object. The volume has to be a directory, not a file.
    # If volume is not defined, no checkpoint file will be used.
    # For example, if you want to use hostpath, the it should look like this:
    #
    #     checkpointFile:
    #       volume:
    #         hostPath:
    #           path: /var/data
    #           type: Directory
    volume:

  # = Configure Splunk HEC connection =
  splunk:
    hec:
      # host to the HEC endpoint [REQUIRED]
      host: http-inputs-ocs.splunkcloud.com
      # token for the HEC [REQUIRED]
      token: "${splunk_metrics_hec_token}"
      # protocol has two options: "http" and "https". Default value: "https"
      # For self signed certficate leave this field blank
      protocol: 
      # indexName tells which index to use, this is optional. If it's not present, will use "main".
      indexName: "${splunk_index}"
      # insecureSSL is a boolean, it indicates should it allow insecure SSL connection (when protocol is "https"). Default value: false.
      # For a self signed certficate this value should be true
      insecureSSL: true
      # The *content* of a PEM-format CA certificate for this client.
      clientCert:
      # The *content* of the private key for this client.
      clientKey:
      # The *content* of a PEM-format CA certificate.
      caFile:
      # The path to a directory containing CA certificates which are in PEM format.
      caPath:
      # indexRouting is a boolean, it indicates whether user wants to route logs to the index with name specified by the user using customFilters. Default is false.
      # If you want to use this feature you will have to set the index key for the record using customFilters.
      # For example,
      # customFilters:
      #   SetIndexFilter:
      #     tag: tail.containers.**
      #     type: jq_transformer
      #     body: jq '.record.index = "my_awesome_index" | .record'
      indexRouting:

  # Create or use existing secret if name is empty default name is used
  secret:
    create: true
    name:

  # Defines which version of image to use, and how it should be pulled.
  image:
    # The domain of the registry to pull the image from
    registry: docker.io
    # The name of the image to pull
    name: splunk/kube-objects
    # The tag of the image to pull
    tag: 1.1.6
    # The policy that specifies when the user wants the images to be pulled
    pullPolicy: IfNotPresent
    # Indicates if the image should be pulled using authentication from a secret
    usePullSecret: false
    # The name of the pull secret to attach to the respective serviceaccount used to pull the image
    pullSecretName:

  # Environment variable for metrics daemonset
  environmentVar:

  # Pod annotations for metrics daemonset
  podAnnotations: 

  # = Resoruce Limitation Configs =
  resources:
    # limits:
    #  cpu: 100m
    #  memory: 200Mi
    requests:
      cpu: 100m
      memory: 200Mi

  # Controls the output buffer for the fluentd daemonset
  # Note that, for memory buffer, if `resources.limits.memory` is set,
  # the total buffer size should not bigger than the memory limit, it should also
  # consider the basic memory usage by fluentd itself.
  # All buffer parameters (except Argument) defined in
  # https://docs.fluentd.org/v1.0/articles/buffer-section#parameters
  # can be configured here.
  buffer:
    "@type": memory
    total_limit_size: 600m
    chunk_limit_size: 20m
    chunk_limit_records: 10000
    flush_interval: 5s
    flush_thread_count: 1
    overflow_action: block
    retry_max_times: 5
    retry_type: periodic

  # Defines which nodes should be selected to deploy the fluentd daemonset.
  nodeSelector:
    beta.kubernetes.io/os: linux

  # This default tolerations allow the daemonset to be deployed on master nodes,
  # so that we can also collect metrics from those nodes.
  tolerations: []

  # Defines node affinity to restrict pod deployment.
  affinity: {}

  # `customFilters` defines the custom filters to be used.
  # This section can be used to define custom filters using plugins like https://github.com/splunk/fluent-plugin-jq
  # Its also possible to use other filters like https://www.fluentd.org/plugins#filter
  #
  # The scheme to define a custom filter is:
  #
  # ```
  # <name>:
  #   tag: <fluentd tag for the filter>
  #   type: <fluentd filter type>
  #   body: <definition of the fluentd filter>
  # ```
  #
  # = fluentd tag for the filter =
  # This is the fluentd tag for the record
  #
  # = fluentd filter type =
  # This is the fluentd filter that the user wants to use for record manipulation.
  #
  # = definition of the fluentd filter =
  # This defines the body/logic for using the filter for record manipulation.
  #
  # For example if you want to define a filter which sets cluster_name field to "my_awesome_cluster" you would the following filter
  # <filter tail.containers.**>
  #  @type jq_transformer
  #  jq '.record.cluster_name = "my_awesome_cluster" | .record'
  # </filter>
  # This can be defined in the customFilters section as follows:
  # ```
  # customFilters:
  #   NamespaceSourcetypeFilter:
  #     tag: tail.containers.**
  #     type: jq_transformer
  #     body: jq '.record.cluster_name = "my_awesome_cluster" | .record'
  # ```
  customFilters: {}
  #
  # You can find more information on indexed fields here - http://dev.splunk.com/view/event-collector/SP-CAAAFB6
  # The scheme to define an indexed field is:
  #
  # ```
  # ["field_1", "field_2"]
  # ```
  #
  # `indexFields` defines the fields from the fluentd record to be indexed.
  # You can find more information on indexed fields here - http://dev.splunk.com/view/event-collector/SP-CAAAFB6
  # The input is in the form of an array(comma separated list) of the values you want to use as indexed fields.
  #
  # For example if you want to define indexed fields for "field_1" and "field_2"
  # you will have to define an indexFields section as follows in values.yaml file.
  # ```
  # indexFields: ["field_1", "field_2"]
  # ```
  # WARNING: The fields being used here must be available inside the fluentd record.
  indexFields: []

## Enabling splunk-kubernetes-metrics will install the `splunk-kubernetes-metrics` chart to a kubernetes
## cluster to collect metrics of the cluster to a Splunk indexer/indexer cluster.
splunk-kubernetes-metrics:
  enabled: true
  # logLevel is to set log level of the Splunk kubernetes metrics collector. Avaiable values are:
  # * debug
  # * info (default)
  # * warn
  # * error
  logLevel:

  rbac:
    # Specifies whether RBAC resources should be created.
    # This should be set to `false` if either:
    # a) RBAC is not enabled in the cluster, or
    # b) you want to create RBAC resources by yourself.
    create: true

  serviceAccount:
    # Specifies whether a ServiceAccount should be created
    create: true
    # The name of the ServiceAccount to use.
    # If not set and create is true, a name is generated using the fullname template
    name: "${splunk_service_account}-metrics"
    # This flag specifies if the user wants to use a secret for creating the serviceAccount,
    # which will be used to get the images from a private registry
    usePullSecrets: false

  podSecurityPolicy:
    # Specifies whether Pod Security Policy resources should be created.
    # This should be set to `false` if either:
    # a) Pod Security Policies is not enabled in the cluster, or
    # b) you want to create Pod Security Policy resources by yourself.
    create: false
    # Specifies whether AppArmor profile should be applied.
    # if set to true, this will add two annotations to PodSecurityPolicy:
    # apparmor.security.beta.kubernetes.io/allowedProfileNames: 'runtime/default'
    # apparmor.security.beta.kubernetes.io/defaultProfileName:  'runtime/default'
    # set to false if AppArmor is not available
    apparmor_security: true
    # apiGroup can be set to "extensions" for Kubernetes < 1.10.
    apiGroup: policy

  # = Splunk HEC Connection =
  splunk:
    # Configurations for HEC (HTTP Event Collector)
    hec:
      # hostname/ip of HEC, REQUIRED.
      host: http-inputs-ocs.splunkcloud.com
      # port to HEC, OPTIONAL. Default value: 8088
      port: 443
      # the HEC token, REQUIRED.
      token: "${splunk_metrics_hec_token}"
      # protocol has two options: "http" and "https". Default value: "https"
      # For self signed certficate leave this field blank
      protocol: 
      # indexName tells which index to use, OPTIONAL. If it's not present, will use "main".
      indexName: "${splunk_metric_index}"
      # insecureSSL is a boolean, it indicates should it allow insecure SSL connection (when protocol is "https"). Default value: false
      # For a self signed certficate this value should be true
      insecureSSL: true
      # The PEM-format CA certificate for this client.
      # NOTE: The content of the certificate itself should be used here, not the file path.
      #       The certificate will be stored as a secret in kubernetes.
      clientCert:
      # The private key for this client.
      # NOTE: The content of the key itself should be used here, not the file path.
      #       The key will be stored as a secret in kubernetes.
      clientKey:
      # The PEM-format CA certificate file.
      # NOTE: The content of the file itself should be used here, not the file path.
      #       The file will be stored as a secret in kubernetes.
      caFile:

  # Create or use existing secret if name is empty default name is used
  secret:
    create: true
    name:

  # Defines which version of image to use, and how it should be pulled.
  image:
    # The domain of the registry to pull the image from
    registry: docker.io
    # The name of the image to pull
    name: splunk/k8s-metrics
    # The tag of the image to pull
    tag: 1.1.6
    # The policy that specifies when the user wants the images to be pulled
    pullPolicy: IfNotPresent
    # Indicates if the image should be pulled using authentication from a secret
    usePullSecret: false
    # The name of the pull secret to attach to the respective serviceaccount used to pull the image
    pullsecretName:

  # Defines which version of image to use, and how it should be pulled.
  imageAgg:
    # The domain of the registry to pull the image from
    registry: docker.io
    # The name of the image to pull
    name: splunk/k8s-metrics-aggr
    # The tag of the image to pull
    tag: 1.1.6
    # The policy that specifies when the user wants the images to be pulled
    pullPolicy: IfNotPresent
    # Indicates if the image should be pulled using authentication from a secret
    usePullSecret: false
    # The name of the pull secret to attach to the respective serviceaccount used to pull the image
    pullsecretName:

  # Environment variable for metrics daemonset
  environmentVar:

  # Environment variable for metrics aggregator pod
  environmentVarAgg:
      
  # Pod annotations for metrics daemonset
  podAnnotations: 

  # Pod annotations for metrics aggregator pod
  podAnnotationsAgg: 

  # Controls the resources used by the fluentd daemonset
  resources:
    fluent:
      limits:
        cpu: 200m
        memory: 300Mi
      requests:
        cpu: 200m
        memory: 300Mi
  # Controls the output buffer for fluentd for the metrics pod
  # Note that, for memory buffer, if `resources.sidecar.limits.memory` is set,
  # the total buffer size should not bigger than the memory limit, it should also
  # consider the basic memory usage by fluentd itself.
  # All buffer parameters (except Argument) defined in
  # https://docs.fluentd.org/v1.0/articles/buffer-section#parameters
  # can be configured here.
  buffer:
    "@type": memory
    total_limit_size: 400m
    chunk_limit_size: 10m
    chunk_limit_records: 10000
    flush_interval: 5s
    flush_thread_count: 1
    overflow_action: block
    retry_max_times: 5
    retry_type: periodic

  # Controls the output buffer for fluentd for the metrics aggregator pod
  aggregatorBuffer:
    "@type": memory
    total_limit_size: 400m
    chunk_limit_size: 10m
    chunk_limit_records: 10000
    flush_interval: 5s
    flush_thread_count: 1
    overflow_action: block
    retry_max_times: 5
    retry_type: periodic

  # Configure how often SCK pulls metrics for its kubenetes sources. 15s is the default where 's' is seconds.
  metricsInterval: 15s

  # Defines which nodes should be selected to deploy the fluentd daemonset.
  nodeSelector:
    beta.kubernetes.io/os: linux

  # This default tolerations allow the daemonset to be deployed on master nodes,
  # so that we can also collect metrics from those nodes.
  tolerations:
    - key: node-role.kubernetes.io/master
      effect: NoSchedule

  # Tolerations for the aggregator pod. We do not really want this running on the master nodes, so we leave this
  # blank by default.
  aggregatorTolerations: {}

  # Defines priorityClassName to assign a priority class to pods.
  priorityClassName:

  # Defines node affinity to restrict pod deployment.
  affinity: {}

  # = Kubernetes Connection Configs =
  kubernetes:
    # The hostname or IP address that kubelet will use to connect to. If not supplied, status.hostIP of the node is used to fetch metrics from the Kubelet API (via the $KUBERNETES_NODE_IP environment variable).
    # Default is "#{ENV['KUBERNETES_NODE_IP']}"
    kubeletAddress:
    # The port that kubelet is listening on. Default is 10250
    kubeletPort:
    # The port that is used to get the metrics using apiserver proxy using ssl for the metrics aggregator
    kubeletPortAggregator:
    # This option is used to get the metrics from summary api on each kubelet using ssl
    useRestClientSSL: true
    # if insecureSSL is set to true, insecure HTTPS API call is allowed, default false
    insecureSSL: false
    # Path to the CA file.
    caFile:
    # Path to the file contains the API token. By default it reads from the file "token" in the `secret_dir`.
    bearerTokenFile:
    # Path of the location where pod's service account's credentials are stored. Usually you don't need to care about this config, the default value should work in most cases.
    secretDir:
    # The cluster name used to tag cluster metrics from the aggregator. Default is cluster_name
    clusterName: "${cluster_name}"

  # `customFilters` defines the custom filters to be used.
  # This section can be used to define custom filters using plugins like https://github.com/splunk/fluent-plugin-jq
  # Its also possible to use other filters like https://www.fluentd.org/plugins#filter
  #
  # The scheme to define a custom filter is:
  #
  # ```
  # <name>:
  #   tag: <fluentd tag for the filter>
  #   type: <fluentd filter type>
  #   body: <definition of the fluentd filter>
  # ```
  #
  # = fluentd tag for the filter =
  # This is the fluentd tag for the record
  #
  # = fluentd filter type =
  # This is the fluentd filter that the user wants to use for record manipulation.
  #
  # = definition of the fluentd filter =
  # This defines the body/logic for using the filter for record manipulation.
  #
  # For example if you want to define a filter which sets cluster_name field to "my_awesome_cluster" you would the following filter
  # <filter tail.containers.**>
  #  @type jq_transformer
  #  jq '.record.cluster_name = "my_awesome_cluster" | .record'
  # </filter>
  # This can be defined in the customFilters section as follows:
  # ```
  # customFilters:
  #   NamespaceSourcetypeFilter:
  #     tag: tail.containers.**
  #     type: jq_transformer
  #     body: jq '.record.cluster_name = "my_awesome_cluster" | .record'
  # ```
  customFilters: {}

