#!/bin/bash
#PBS -P Project
#PBS -l select=1:ncpus=9:ngpus=1:mem=30gb
#PBS -l walltime=100:50:59
#PBS -e PBSout/
#PBS -o PBSout/
#PBS -j oe

# consistent with Usyd Artemis (single node GPU)
cd "PBS_O_WORKDIR"
DATA_DIR="/project/RDS-FSC-phys_DL-RW/PhD_code/Anomalous-diffusion-dynamics-of-SGD-master"
cd ${DATA_DIR}

# load modules
module load 

# params=`sed "${PBS_ARRAY_INDEX}q;d" job_params`
# param_array=( $params )

# training DNN
python -m main --model=fc1 --epochs=500  --batch_size=1024

# hessian (make sure download: https://github.com/noahgolmant/pytorch-hessian-eigenthings)
python hessian.compute_hessian_eig_GZ.py --cuda --batch_size=128 --model=fc1 --model_folder='trained_nets/fc1_sgd_lr=0.1_bs=1024_wd=0_mom=0_save_epoch=1' --num_eigenthings=40

# MATLAB post analysis 
MATLAB_SOURCE_PATH1="/project/RDS-FSC-phys_DL-RW/PhD_code/Anomalous-diffusion-dynamics-of-SGD-master/post_analysis"
MATLAB_PROCESS_FUNC="SGD_analysis_step_level"

matlab  -nodisplay  -r "cd('${MATLAB_SOURCE_PATH1}'), addpath(genpath(cd)), \
                                                   cd('${PBS_O_WORKDIR}'), \
						   cd('${DATA_DIR}'), ${MATLAB_PROCESS_FUNC}, exit"