%{
wrapper_SCEPT_FL
Author: Tom Bullock (adapted from Tyler scripts)
Date: 07.23.18

%}

function wrapper_SCPET_FL(sjNum,rDir)

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
%dicomConvert_VO2_FL
%realignEstimateReslice_VO2_FL
%%%segmentStrip_VO2_FL
%brainMask_VO2(0) % 0 = no smoothing, 1 = smoothing
pre_coregister_anatomical2functional_FL

%% close SPM session
close all



return
