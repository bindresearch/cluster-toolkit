In order to create a cluster to run calculations on Google Cloud, follow the instructions below: 

The file `hpc-slurm6-apptainer.yaml` (or any of the other `.yaml` files here) contains all of the configuration information required to setup the cluster (e.g., how large will the cluster be, which GPU/CPU models it will use, which region will it run in, programs installed, etc.).

Make sure you compile `gcluster` by following the instructions in the root directory of this repository.

Run `1_gcluster_create.sh`, to prepare terraform config files (each taking care of a specific part of the setup). These files shouldn't have to be manually modified.

Run `2_gcluster_deploy.sh`, to deploy the cluster on the cloud. This script essentially runs all commands defined in the terraform files created previously. 
* you will have to interactively apply changes proposed.
* this step takes the longest to run and will create VM instances (a login node, a controller node, and a spack node for installations).
* All other types of ressources (network, storage) required to make the cluster work will also be created.
* The login and controller nodes will be accessible immediately, but programs installed via spack may take some time ot install (1/2h)

Ressources will be used even when jobs are not submitted/running, so it is best to free them up if the cluster will not be used for a while. This can be done with the following script: `3_gcluster_destroy.sh`, 
