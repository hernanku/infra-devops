get-identity:
	aws sts get-caller-identity

init:
	terraform init -upgrade

state-list:
	terraform state list

plan:
	terraform plan -var-file=shared_vars.tfvars

apply:
	terraform apply -var-file=shared_vars.tfvars -auto-approve

destroy:
	terraform destroy -var-file=shared_vars.tfvars -auto-approve










