#!/bin/zsh

# Create a basic ubuntu 2024 instance

INSTANCE_NAME="my-ubuntu-test-instance-3"

gcloud compute instances create ${INSTANCE_NAME} \
    --project=esoteric-kiln-463912-m2 \
    --zone=europe-west1-b \
    --machine-type=n1-standard-1 \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
    --metadata=enable-osconfig=TRUE \
    --metadata-from-file startup-script=startup.sh \
    --maintenance-policy=TERMINATE \
    --provisioning-model=STANDARD \
    --service-account=891723074586-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --accelerator=count=1,type=nvidia-tesla-t4 \
    --tags=http-server,https-server \
    --create-disk=auto-delete=yes,boot=yes,device-name=${INSTANCE_NAME},disk-resource-policy=projects/esoteric-kiln-463912-m2/regions/europe-west1/resourcePolicies/default-schedule-1,image=projects/ubuntu-os-cloud/global/images/ubuntu-minimal-2404-noble-amd64-v20250701,mode=rw,size=200,type=pd-balanced \
    --shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=goog-ops-agent-policy=v2-x86-template-1-4-0,goog-ec-src=vm_add-gcloud \
    --reservation-affinity=any


printf 'agentsRule:\n  packageState: installed\n  version: latest\ninstanceFilter:\n  inclusionLabels:\n  - labels:\n      goog-ops-agent-policy: v2-x86-template-1-4-0\n' > config.yaml



gcloud compute instances ops-agents policies create goog-ops-agent-v2-x86-template-1-4-0-europe-west1-b \
    --project=esoteric-kiln-463912-m2 \
    --zone=europe-west1-b \
    --file=config.yaml


#
# Add some default scripts to apt-get update and install basic drivers + cuda container toolkit.
# 

