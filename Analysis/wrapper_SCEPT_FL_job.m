%{
wrapper_SCEPT_FL_job
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
d=[dir('sj112*');dir('sj119*');dir('sj121*');dir('sj125*');dir('sj127*');dir('sj133*');];
cd ..

% run in parallel or serial?
runParallel = 0;

if runParallel
    thisFunction = 'wrapper_SCPET_FL.m';
    s = parcluster;
    s.ResourceTemplate='-l nodes=^N^:ppn=4,mem=7GB';
    job=createJob(s,'Name','Tom_Job');
    job.AttachedFiles = {'wrapper_SCPET_FL.m'};
end

for iSub =1:length(d)
    sjNum = d(iSub).name;
    disp(['Processing ' sjNum])
    if runParallel
        job.createTask(@wrapper_SCPET_FL,0,{sjNum,rDir})
    else
        wrapper_SCPET_FL(sjNum,rDir)
    end
end

if runParallel
    job.submit
end
