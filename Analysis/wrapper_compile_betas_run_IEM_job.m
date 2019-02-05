%{
singleTrialModeling_job
Author: Tom
Date: 04.16.18
 
%}

clear 
close all

subjects = [119,121,125,127,130,133]; % 112 not ready yet

subjects = 112;

% define directory with subject data
%%rDir = '/home/bullock/Scan_CPET/Subject_Data';

% add analysis scripts folder to path
addpath(genpath('/home/bullock/Scan_CPET/Analysis'))

% % cd to subject data folder and get files
% cd(rDir);
% d=dir('sj*');
% cd ..

thisFunction = 'wrapper_compile_betas_run_IEM.m';
s = parcluster;
s.ResourceTemplate='-l nodes=^N^:ppn=4,mem=7GB';
job=createJob(s,'Name','Tom_Job');
job.AttachedFiles = {'wrapper_compile_betas_run_IEM.m','compile_betas_IEM.m','model_runIEM.m'};

for iSub =1:length(subjects)
    sjNum=subjects(iSub);
    for thisSession=1:2
        disp(['Processing ' sjNum])
        job.createTask(@wrapper_compile_betas_run_IEM.m,0,{sjNum,thisSession})
    end
end
job.submit
