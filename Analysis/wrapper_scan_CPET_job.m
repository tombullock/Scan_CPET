%{
IEM_run_model_hilbert_job
Author: Tom
Date: 04.16.18
 
%}

clear 
close all

% define directory with subject data
rDir = '/home/bullock/Scan_CPET/Subject_Data';

% add analysis scripts folder to path
addpath(genpath('/home/bullock/VO2_fMRI/Analysis'))

% cd to subject data folder and get files
cd(rDir);
d=dir('sj*');
cd ..

thisFunction = 'wrapper_scan_CPET.m';

s = parcluster;
s.ResourceTemplate='-l nodes=^N^:ppn=4,mem=7GB';
job=createJob(s,'Name','Tom_Job');

job.AttachedFiles = {'wrapper_scan_CPET.m'};

%%% ONLY FIRST 3
for iSub =1:3;%length(d)
    sjNum = d(iSub).name;
    disp(['Processing ' sjNum])
    job.createTask(@wrapper_scan_CPET,0,{sjNum,rDir})
end
job.submit
