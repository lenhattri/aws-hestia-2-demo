SHELL := /bin/bash

TF_DIR ?= live
ENV ?= dev
STACK ?= vpc

init:
cd $(TF_DIR)/$(ENV)/$(STACK) && terraform init

plan:
cd $(TF_DIR)/$(ENV)/$(STACK) && terraform init -upgrade && terraform validate && terraform plan

apply:
cd $(TF_DIR)/$(ENV)/$(STACK) && terraform init && terraform apply -auto-approve

destroy:
cd $(TF_DIR)/$(ENV)/$(STACK) && terraform init && terraform destroy

fmt:
terraform fmt -recursive

validate:
terraform fmt -check -recursive
find $(TF_DIR) -maxdepth 2 -mindepth 2 -type d -exec bash -c 'cd "{}" && terraform init -backend=false >/dev/null && terraform validate' \;

lint:
tflint --recursive

tfsec:
tfsec .

.PHONY: init plan apply destroy fmt validate lint tfsec
