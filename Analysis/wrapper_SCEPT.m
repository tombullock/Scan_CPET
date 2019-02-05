%{
wrapper_SCEPT
Author: Tom Bullock (adapted from Tyler scripts)
Date: 07.23.18

%}

function wrapper_SCEPT(sjNum,rDir)

%% ADD SUBJECT RULES (these subjects have no task data, only resting)
if sum(strcmp(sjNum,{'sj115','sj116','sj124'}))==1
    taskDataPresent=0;
else
    taskDataPresent=1;
end

%% add analysis scripts folder to path
addpath(genpath('/home/bullock/Scan_CPET/Analysis'))
addpath(genpath('/home/bullock/spm12'))

%% cd to subject folder
thisDir = [rDir '/' num2str(sjNum)];
cd(thisDir);

%% open an SPM session (necessary to save pdf outputs)
spm fmri

%% pre-process ALL fMRI data
pre_dicomConvert
pre_realignEstimateReslice(taskDataPresent) % 0=no task data, 1=task data (some subs - 115,116,124 - only have resting data)
pre_segmentStrip
pre_brainMask(0) % 0 = no smoothing (single trial), 1 = smoothing (resting state)
pre_coregister_anatomical2functional


%% pre-process for RESTING state analyses (this is incomplete 020519)
smoothDataForRestingState(taskDataPresent) % 0=no task data, 1=task data (some subs - 115,116,124 - only have resting data)

% take preprocessed RS data and throw into a 4D nifti file
% Global signal scaling (use median)
% Linear detrending
% Brain Wavelet Toolbox (just resting)
% nus regression (load in the motion params, stored in folder, begin with
% rp...detrend the data)
% filter the data (either bandpass OR with wavelet decomp (both have adv or
% disad)
%% connectivity analysis
%schaefer atlas - github and CC picture


%% close SPM session
close all

return
