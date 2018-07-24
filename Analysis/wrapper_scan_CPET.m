%{
wrapper_fMRI_VO2
Author: Tom Bullock (adapted from Tyler scripts)
Date: 07.23.18

%}

function wrapper_scan_CPET(sjNum,rDir)

%rDir = '/home/bullock/VO2_fMRI/Subject_Data';

%% add analysis scripts folder to path
addpath(genpath('/home/bullock/Scan_CPET/Analysis'))
%spm_rmpath
addpath /home/bullock/spm12

%% cd to subject data folder and get files
%cd(rDir);
%d=dir('sj*');

%for iSub = 1:1;%length(d)

%% cd to subject folder
thisDir = [rDir '/' num2str(sjNum)];
cd(thisDir);

%% open an SPM session (necessary to save pdf outputs)
spm fmri

%% pre-process fMRI data
dicomConvert_VO2
realignEstimateReslice_VO2
segmentStrip_VO2
brainMask_VO2(0) % 0 = no smoothing, 1 = smoothing
coregisterEstimateReslice

%% close SPM session
close all

%% organize data and run IEM (subs 112,119,121,125,127,130,133)
% singleTrialModeling
% compile_Betas_For_Modeling
% runIEM_VO2

return
