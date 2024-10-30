#!/bin/bash

#SBATCH --partition=amilan
#SBATCH --qos=normal         # normal=24h, long=7-day
#SBATCH --time=10:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --account=ucb-general
#SBATCH --output=prod.%j.out
#SBATCH --job-name=prod

module purge
module load gcc/11.2.0
module load openmpi/4.1.1
module load anaconda
conda activate amber

top_fn="IID_solvated.prmtop"
init_config="IID_solvated.inpcrd"

# minimize
mpirun -np 2 $AMBERHOME/bin/sander -O -i 01_min.in -o 01_min.out -p $top_fn -c $init_config -r 01_min.ncrst -inf 01_min.mdinfo

# heat
mpirun -np 2 $AMBERHOME/bin/sander -O -i 02_heat.in -o 02_heat.out -p $top_fn -c 01_min.ncrst -r 02_heat.ncrst -inf 02_heat.mdinfo -x 02_heat.nc

# equilibrate
mpirun -np 2 $AMBERHOME/bin/sander -O -i 03_equil.in -o 03_equil.out -p $top_fn -c 02_heat.ncrst -r 03_equil.ncrst -inf 03_equil.mdinfo -x 03_equil.nc

# short production
mpirun -np 2 $AMBERHOME/bin/sander -O -i 04_prod.in -o 04_prod.out -p $top_fn -c 03_equil.ncrst -r 04_prod.ncrst -inf 04_prod.mdinfo -x 04_prod.nc
