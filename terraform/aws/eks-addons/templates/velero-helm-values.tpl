##
## Configuration settings that directly affect the Velero deployment YAML.
##

# Details of the container image to use in the Velero deployment & daemonset (if
# enabling restic). Required.
image:
  repository: velero/velero
  tag: v1.5.1
  # Digest value example: sha256:d238835e151cec91c6a811fe3a89a66d3231d9f64d09e5f3c49552672d271f38.
  # If used, it will take precedence over the image.tag.
  # digest:
  pullPolicy: IfNotPresent
  # One or more secrets to be used when pulling images
  imagePullSecrets: []
  # - registrySecretName

# Annotations to add to the Velero deployment's. Optional.
#
# If you are using reloader use the following annotation with your VELERO_SECRET_NAME
annotations: {}
# secret.reloader.stakater.com/reload: "<VELERO_SECRET_NAME>"

# Labels to add to the Velero deployment's. Optional.
labels: {}

# Annotations to add to the Velero deployment's pod template. Optional.
#
# If using kube2iam or kiam, use the following annotation with your AWS_ACCOUNT_ID
# and VELERO_ROLE_NAME filled in:
podAnnotations: {}
  #  iam.amazonaws.com/role: "arn:aws:iam::<AWS_ACCOUNT_ID>:role/<VELERO_ROLE_NAME>"

# Additional pod labels for Velero deployment's template. Optional
# ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
podLabels: {}

# Resource requests/limits to specify for the Velero deployment.
# https://velero.io/docs/v1.6/customize-installation/#customize-resource-requests-and-limits
resources:
  requests:
    cpu: 500m
    memory: 128Mi
  limits:
    cpu: 1000m
    memory: 512Mi

# Configure the dnsPolicy of the Velero deployment
# See: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy
dnsPolicy: ClusterFirst

# Init containers to add to the Velero deployment's pod spec. At least one plugin provider image is required.
initContainers: 
  - name: velero-plugin-for-aws
    image: velero/velero-plugin-for-aws:v1.2.0
    imagePullPolicy: IfNotPresent
    volumeMounts:
      - mountPath: /target
        name: plugins

# SecurityContext to use for the Velero deployment. Optional.
# Set fsGroup for `AWS IAM Roles for Service Accounts`
# see more informations at: https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html
podSecurityContext: {}
  # fsGroup: 1337

# Container Level Security Context for the 'velero' container of the Velero deployment. Optional.
# See: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container
containerSecurityContext: {}
  # allowPrivilegeEscalation: false
  # capabilities:
  #   drop: ["ALL"]
  #   add: []
  # readOnlyRootFilesystem: true

# Pod priority class name to use for the Velero deployment. Optional.
priorityClassName: ""

# Tolerations to use for the Velero deployment. Optional.
tolerations: []

# Affinity to use for the Velero deployment. Optional.
affinity: {}

# Node selector to use for the Velero deployment. Optional.
nodeSelector: {}

# Extra volumes for the Velero deployment. Optional.
extraVolumes: []

# Extra volumeMounts for the Velero deployment. Optional.
extraVolumeMounts: []

# Settings for Velero's prometheus metrics. Enabled by default.
metrics:
  enabled: true
  scrapeInterval: 30s
  scrapeTimeout: 10s

  # service metdata if metrics are enabled
  service:
    annotations: {}
    labels: {}

  # Pod annotations for Prometheus
  podAnnotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "8085"
    prometheus.io/path: "/metrics"

  serviceMonitor:
    enabled: false
    additionalLabels: {}
    # ServiceMonitor namespace. Default to Velero namespace.
    # namespace:

kubectl:
  image:
    repository: docker.io/bitnami/kubectl
    # Digest value example: sha256:d238835e151cec91c6a811fe3a89a66d3231d9f64d09e5f3c49552672d271f38.
    # If used, it will take precedence over the kubectl.image.tag.
    # digest:
    # kubectl image tag. If used, it will take precedence over the cluster Kubernetes version.
    tag: 1.21
  # Annotations to set for the upgrade/cleanup job. Optional.
  annotations: {}
  # Labels to set for the upgrade/cleanup job. Optional.
  labels: {}

# This job upgrades the CRDs.
upgradeCRDs: false

# This job is meant primarily for cleaning up CRDs on CI systems.
# Using this on production systems, especially those that have multiple releases of Velero, will be destructive.
cleanUpCRDs: false

##
## End of deployment-related settings.
##


##
## Parameters for the `default` BackupStorageLocation and VolumeSnapshotLocation,
## and additional server settings.
##
configuration:
  # Cloud provider being used (e.g. aws, azure, gcp).
  provider: aws

  # Parameters for the `default` BackupStorageLocation. See
  # https://velero.io/docs/v1.6/api-types/backupstoragelocation/
  backupStorageLocation:
    # name is the name of the backup storage location where backups should be stored. If a name is not provided,
    # a backup storage location will be created with the name "default". Optional.
    name: '${velero_backup_loaction_name}'
    # provider is the name for the backup storage location provider. If omitted
    # `configuration.provider` will be used instead.
    provider: aws
    # bucket is the name of the bucket to store backups in. Required.
    bucket: '${velero_backup_bucket}'
    # caCert defines a base64 encoded CA bundle to use when verifying TLS connections to the provider. Optional.
    # caCert:
    # prefix is the directory under which all Velero data should be stored within the bucket. Optional.
    prefix: '${velero_backup_bucket_key}'
    # default indicates this location is the default backup storage location. Optional.
    default: true
    # Additional provider-specific configuration. See link above
    # for details of required/optional fields for your provider.
    config: 
     region: us-east-1
    #  s3ForcePathStyle:
    #  s3Url:
    #  kmsKeyId:
    #  resourceGroup:


  # Parameters for the `default` VolumeSnapshotLocation. See
  # https://velero.io/docs/v1.6/api-types/volumesnapshotlocation/
  volumeSnapshotLocation:
    # name is the name of the volume snapshot location where snapshots are being taken. Required.
    name: '${velero_backup_snapshot_name}'
    # provider is the name for the volume snapshot provider. If omitted
    # `configuration.provider` will be used instead.
    provider: aws
    # Additional provider-specific configuration. See link above
    # for details of required/optional fields for your provider.
    config: 
     region: us-east-1
  #    apiTimeout:
  #    resourceGroup:


  # These are server-level settings passed as CLI flags to the `velero server` command. Velero
  # uses default values if they're not passed in, so they only need to be explicitly specified
  # here if using a non-default value. The `velero server` default values are shown in the
  # comments below.
  # --------------------
  # `velero server` default: 1m
  backupSyncPeriod:
  # `velero server` default: 1h
  resticTimeout:
  # `velero server` default: namespaces,persistentvolumes,persistentvolumeclaims,secrets,configmaps,serviceaccounts,limitranges,pods
  restoreResourcePriorities:
  # `velero server` default: false
  restoreOnlyMode:
  # `velero server` default: 20.0
  clientQPS:
  # `velero server` default: 30
  clientBurst:
  # `velero server` default: empty
  disableControllers:
  #

  # additional key/value pairs to be used as environment variables such as "AWS_CLUSTER_NAME: 'yourcluster.domain.tld'"
  extraEnvVars: {}

  # Comma separated list of velero feature flags. default: empty
  features:

  # Set log-level for Velero pod. Default: info. Other options: debug, warning, error, fatal, panic.
  logLevel: info

  # Set log-format for Velero pod. Default: text. Other option: json.
  logFormat:

  # Set true for backup all pod volumes without having to apply annotation on the pod when used restic Default: false. Other option: false.
  defaultVolumesToRestic:

##
## End of backup/snapshot location settings.
##


##
## Settings for additional Velero resources.
##

rbac:
  # Whether to create the Velero role and role binding to give all permissions to the namespace to Velero.
  create: true
  # Whether to create the cluster role binding to give administrator permissions to Velero
  clusterAdministrator: true

# Information about the Kubernetes service account Velero uses.
serviceAccount:
  server:
    create: true
    name: '${velero_service_account_name}'
    annotations:
    labels:

# Info about the secret to be used by the Velero deployment, which
# should contain credentials for the cloud provider IAM account you've
# set up for Velero.
credentials:
  # Whether a secret should be used as the source of IAM account
  # credentials. Set to false if, for example, using kube2iam or
  # kiam to provide IAM credentials for the Velero pod.
  useSecret: true
  # Name of the secret to create if `useSecret` is true and `existingSecret` is empty
  name: velero-creds
  # Name of a pre-existing secret (if any) in the Velero namespace
  # that should be used to get IAM account credentials. Optional.
  existingSecret: 
  # Data to be stored in the Velero secret, if `useSecret` is true and `existingSecret` is empty.
  # As of the current Velero release, Velero only uses one secret key/value at a time.
  # The key must be named `cloud`, and the value corresponds to the entire content of your IAM credentials file.
  # Note that the format will be different for different providers, please check their documentation.
  # Here is a list of documentation for plugins maintained by the Velero team:
  # [AWS] https://github.com/vmware-tanzu/velero-plugin-for-aws/blob/main/README.md
  # [GCP] https://github.com/vmware-tanzu/velero-plugin-for-gcp/blob/main/README.md
  # [Azure] https://github.com/vmware-tanzu/velero-plugin-for-microsoft-azure/blob/main/README.md
  secretContents: 
   cloud: |
     [default]
     aws_access_key_id="${velero_user_aws_access_key}"
     aws_secret_access_key="${velero_user_aws_secret_access_key}"
  # additional key/value pairs to be used as environment variables such as "DIGITALOCEAN_TOKEN: <your-key>". Values will be stored in the secret.
  extraEnvVars: 
  # Name of a pre-existing secret (if any) in the Velero namespace
  # that will be used to load environment variables into velero and restic.
  # Secret should be in format - https://kubernetes.io/docs/concepts/configuration/secret/#use-case-as-container-environment-variables
  extraSecretRef: ""

# Whether to create backupstoragelocation crd, if false => do not create a default backup location
backupsEnabled: true
# Whether to create volumesnapshotlocation crd, if false => disable snapshot feature
snapshotsEnabled: true

# Whether to deploy the restic daemonset.
deployRestic: true

restic:
  podVolumePath: /var/lib/kubelet/pods
  privileged: false
  # Pod priority class name to use for the Restic daemonset. Optional.
  priorityClassName: ""
  # Resource requests/limits to specify for the Restic daemonset deployment. Optional.
  # https://velero.io/docs/v1.6/customize-installation/#customize-resource-requests-and-limits
  resources:
    requests:
      cpu: 500m
      memory: 512Mi
    limits:
      cpu: 1000m
      memory: 1024Mi

  # Tolerations to use for the Restic daemonset. Optional.
  tolerations: []

  # Annotations to set for the Restic daemonset. Optional.
  annotations: {}

  # labels to set for the Restic daemonset. Optional.
  labels: {}

  # Extra volumes for the Restic daemonset. Optional.
  extraVolumes: []

  # Extra volumeMounts for the Restic daemonset. Optional.
  extraVolumeMounts: []

  # Configure the dnsPolicy of the Restic daemonset
  # See: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy
  dnsPolicy: ClusterFirst

  # SecurityContext to use for the Velero deployment. Optional.
  # Set fsGroup for `AWS IAM Roles for Service Accounts`
  # see more informations at: https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html
  podSecurityContext:
    runAsUser: 0
    # fsGroup: 1337

  # Container Level Security Context for the 'restic' container of the restic DaemonSet. Optional.
  # See: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container
  containerSecurityContext: {}

  # Node selector to use for the Restic daemonset. Optional.
  nodeSelector: {}

# Backup schedules to create.
# Eg:
schedules:
  mybackup:
    disabled: false
    labels: {}
    annotations: {}
    schedule: "0 * * * *"
    useOwnerReferencesInBackup: true
    template:
      ttl: "500h"
      # includedNamespaces:
      # - foo
# schedules:
#   mybackup:
#     disabled: false
#     labels:
#       cost_center: '{cost_center}'
#       cluster_name: '{cluster_name}'
#       environment: '{environment}'
#     annotations:
#       cost_center: '{cost_center}'
#       cluster_name: '{cluster_name}'
#       environment: '{environment}'
#     schedule: "0 * * * *"
#     useOwnerReferencesInBackup: true
#     template:
#       ttl: "500h"

# Velero ConfigMaps.
# Eg:
# configMaps:
#   restic-restore-action-config:
#     labels:
#       velero.io/plugin-config: ""
#       velero.io/restic: RestoreItemAction
#     data:
#       image: velero/velero-restic-restore-helper:v1.6.3
configMaps: {}

##
## End of additional Velero resource settings.
##

