#!/bin/zsh

# Create a basic ubuntu 2024 instance

INSTANCE_NAME="benchmark-gromacs-gpu-docker"

PROJECT_ID="esoteric-kiln-463912-m2"

AREA="europe-west1"
ZONE="${AREA}-b"

CPU_MACHINE="n1-standard-1" # compare with n1-standard-2 and n1-standard-4
GPU_TYPE="nvidia-tesla-t4" # compare to "nvidia-l4" (works with g2 CPUs),  "nvidia-tesla-p4" or "nvidia-tesla-p100"

INSTANCE_NAME="${INSTANCE_NAME}-${GPU_TYPE}"

gcloud compute instances create ${INSTANCE_NAME} \
    --project=${PROJECT_ID} \
    --zone=${ZONE} \
    --machine-type=${CPU_MACHINE} \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
    --metadata=enable-osconfig=TRUE,docker_user=candide_champion_bind_research_c \
    --metadata-from-file startup-script=startup.sh \
    --maintenance-policy=TERMINATE \
    --provisioning-model=STANDARD \
    --service-account=891723074586-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --accelerator=count=1,type=${GPU_TYPE} \
    --tags=http-server,https-server \
    --create-disk=auto-delete=yes,boot=yes,device-name=${INSTANCE_NAME},image=projects/ubuntu-os-cloud/global/images/ubuntu-minimal-2404-noble-amd64-v20250701,mode=rw,size=200,type=pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=goog-ops-agent-policy=v2-x86-template-1-4-0,goog-ec-src=vm_add-gcloud \
    --reservation-affinity=any


#printf 'agentsRule:\n  packageState: installed\n  version: latest\ninstanceFilter:\n  inclusionLabels:\n  - labels:\n      goog-ops-agent-policy: v2-x86-template-1-4-0\n' > config.yaml

#gcloud compute instances ops-agents policies create goog-ops-agent-v2-x86-template-1-4-0-europe-west1-b \
#    --project=${PROJECT_ID} \
#    --zone=${ZONE} \
#    --file=config.yaml

