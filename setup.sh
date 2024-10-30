#!/bin/bash

# load modules and activate amber
module load anaconda
conda activate amber

# NOTE: replace UNL with IID in the .pdb file from avogadro

# convert the avogadro output to an AMBER format
pdb4amber isoindole.pdb > IID.pdb --reduce

# generate the mol2 file
antechamber -i IID.pdb -fi pdb -o IID.mol2 -fo mol2 -c bcc -s 2 -nc 0

# generate the force field paramters
parmchk2 -i IID.mol2 -f mol2 -o IID.frcmod

# generate lib file
tleap -f tleap.in

# build TIP3P water box
tleap -f tleap2.in

# Check the last line of sqm.out and see if it contains "Calculation Completed"
if tail -n 2 sqm.out | grep -q "Calculation Completed"; then
    # If it does, create the directory "antechamber-output"
    mkdir -p antechamber-output
    mv ANTECHAMBER* antechamber-output
    mv ATOMTYPE.INF antechamber-output
    mv stdout_* antechamber-output
    mv reduce_info.log antechamber-output
    mv sqm.* antechamber-output
fi
