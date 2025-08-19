### 1) How to create an autoscaling cluster to run calculations on Google Cloud:: 

The file `hpc-slurm6-apptainer.yaml` (or any of the other `.yaml` files provided here) contains all of the configuration information required to setup the cluster (e.g., how large will the cluster be, which GPU/CPU models it will use, which region will it run in, programs installed, etc.). Make sure you compile `gcluster` by following the instructions in the root directory of this repository.

Run `1_gcluster_create.sh`, to prepare terraform config files (each taking care of a specific part of the setup). These files shouldn't have to be manually modified, but can if need be.

Run `2_gcluster_deploy.sh`, to deploy the cluster on the cloud. This script essentially runs all commands defined in the terraform files created previously. 
* You will have to interactively apply changes proposed.
* This step will create VM instances and all other types of ressources (network, storage) required to make the cluster work.
    * For an apptainer cluster, this first creates a packer VM which creates a template image with necessary installs (defined by user). - Takes ~10minutes
    * For a spack cluster, this first creates a spack node which performs all necessary installs (defined by user). - Takes ~2hours 
    * Certain nodes may be available before all programs are installed (i.e. before startup script completion).
* Ressources are **billed** even when jobs are not submitted/running, so it is best to free them up if the cluster will not be used for a while.

To destroy a cluster, run: `3_gcluster_destroy.sh`. 

### 2) How to run apptainer images on the cluster: 

Make sure apptainer is installed, as well as any dependency to run the calculation on a GPU (nvidia drivers) or multi-node CPU (OpenMPI). 
Download a publicly hosted image and convert it to apptainer format (this takes a few minutes): `apptainer pull gromacs-plumed.sif docker://ghcr.io/candidechamp/gromacs-plumed:latest`

To submit calculations in jobs, copy the following scripts and submit them with: `sbatch submit_gpu.sh` or  `sbatch submit_cpu.sh`
```
# submit_cpu_singlenode.sh

#!/bin/bash
#SBATCH --job-name=test-job-cpu
#SBATCH --partition=compute
#SBATCH --time=00:30:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4 # I made a minimal cluster here.
#SBATCH --cpus-per-task=1

wget https://hpc.fau.de/files/2022/02/rnanvt-nhr-fau.zip
unzip rnanvt-nhr-fau.zip

# no need for -ntomp 4, gromacs will figure this out by itself.
apptainer run /home/candide_champion_bind_research_c/gromacs-plumed.sif gmx_mpi mdrun -s rnanvt-nhr-fau.tpr -deffnm output -nsteps 60000 -resetstep 50000
```

```
# submit_gpu.sh

#!/bin/bash
#SBATCH --job-name=test-job-gpu
#SBATCH --partition=gpu
#SBATCH --time=00:30:00

wget https://hpc.fau.de/files/2022/02/rnanvt-nhr-fau.zip
unzip rnanvt-nhr-fau.zip

apptainer run --nv /home/candide_champion_bind_research_c/gromacs-plumed.sif gmx_mpi mdrun -s rnanvt-nhr-fau.tpr -deffnm output -nsteps 60000 -resetstep 50000 # additional gromacs options ... 
```
```
# submit_gpu_mpi.sh (multiple replicas on a single GPU)

#!/bin/bash
#SBATCH --job-name=test-job-gpu
#SBATCH --partition=gpu
#SBATCH --time=00:30:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2 #note: maximum here is the number of CPUs on the GPU node
#SBATCH --cpus-per-task=1

# run this in an empty directory

wget https://hpc.fau.de/files/2022/02/rnanvt-nhr-fau.zip && unzip rnanvt-nhr-fau.zip

mkdir dir0 dir1 
cp rnanvt-nhr-fau.tpr dir0/topol.tpr
cp rnanvt-nhr-fau.tpr dir1/topol.tpr 

/opt/openmpi/bin/mpirun -np 2 apptainer run --nv /home/candide_champion_bind_research_c/gromacs-plumed.sif gmx_mpi mdrun -multidir dir0 dir1 
```
