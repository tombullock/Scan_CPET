%{
singleTrialModeling_job
Author: Tom
Date: 04.16.18
 
%}

clear 
close all

subjects = [112,119,121,125,127,130,133];

subjects = 112;

% define directory with subject data
%%rDir = '/home/bullock/Scan_CPET/Subject_Data';

% add analysis scripts folder to path
addpath(genpath('/home/bullock/Scan_CPET/Analysis'))

% % cd to subject data folder and get files
% cd(rDir);
% d=dir('sj*');
% cd ..

thisFunction = 'singleTrialModeling.m';

s = parcluster;
s.ResourceTemplate='-l nodes=^N^:ppn=4,mem=7GB';
job=createJob(s,'Name','Tom_Job');

job.AttachedFiles = {'singleTrialModeling.m'};

for iSub =1:length(subjects)
    sjNum=subjects(iSub);
    for thisSession=1:2
        disp(['Processing ' sjNum])
        job.createTask(@singleTrialModeling,0,{sjNum,thisSession})
    end
end
job.submit