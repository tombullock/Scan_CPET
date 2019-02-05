# Scan_CPET

Contains matlab scripts for processing fMRI data collected for Scan_CPET project.

From pre-processing > IEM 

See wrapper function for overview of pipeline.

NOTE THAT SUBJECTS 115,116,124 are RESTING STATE PRE vs. POST ONLY!

# fMRI PREPROCESSING

`pre_dicomConvert.m`                        Convert dicom (raw scanner files) to nifti files (SPM compatible)
`pre_realignEstimateReslice.m`              Realign, estimate, reslice data
`pre_coregister_anatomical2functional.m`    Co-register anatomical scan (T1) to functional scans
`pre_brainMask.m`                           Create brain mask     
`pre_segmentStrip.m`                        Isolate white/grey matter 
`Report_FWD.m`                              Generate a report for framewise displacement on a per subject and condition basis

`wrapper_SCEPT.m`                           Preprocessing wrapper.


# IEM PROCESSING PIPELINE

`model_getSingleTrials.m`   Run model to obtain one beta.nii file for each trial (472 betas)
`compile_betas_IEM.m`       Extracts the voxel data from the beta .nii files into matlab matrices
`model_runIEM.m`            Run IEM and obtain CTFs
`plot_CTFs.m`               Plot CTFs

`wrapper_compile_betas_run_IEM.m` Wrapper function to compile all the betas and run the IEM