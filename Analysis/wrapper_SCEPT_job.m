%{
wrapper_SCEPT_job
Author: Tom
Date: 04.16.18
 
%}

clear 
close all

% define directory with subject data
rDir = '/home/bullock/Scan_CPET/Subject_Data';

% add analysis scripts folder to path
addpath(genpath('/home/bullock/Scan_CPET/Analysis'))

% cd to subject data folder and get files
cd(rDir);
%d=[dir('sj115*');dir('sj116*');dir('sj124*')];
d=dir('sj*'); % 133 works
cd ..

% run in parallel or serial?
runParallel = 1;

if runParallel
    thisFunction = 'wrapper_scan_CPET.m';
    s = parcluster;
    s.ResourceTemplate='-l nodes=^N^:ppn=4,mem=7GB';
    job=createJob(s,'Name','Tom_Job');
    job.AttachedFiles = {'wrapper_scan_CPET.m'};
end

for iSub =1:length(d)
    sjNum = d(iSub).name;
    disp(['Processing ' sjNum])
    if runParallel
        job.createTask(@wrapper_scan_CPET,0,{sjNum,rDir})
    else
        wrapper_scan_CPET(sjNum,rDir)
    end
end

if runParallel
    job.submit
end