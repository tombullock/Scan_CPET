%{
model_getSingleTrials_job
Author: Tom
Date: 04.16.18
 
%}

clear 
close all

% run in parallel?
runInParallel=1;

%subjects = [112,119,121,125,127,130,133]; % already processed sj list (with FL)
%subjects = [101,103,107,109,111,112,113,119,121,125,127,130,133,135]; % not all processed (14th oct 2019)
subjects = [101,103,107,109,111,113,135];

%%subjects = 112;

% define directory with subject data
%%rDir = '/home/bullock/Scan_CPET/Subject_Data';

% add analysis scripts folder to path
addpath(genpath('/home/bullock/Scan_CPET/Analysis'))

% % cd to subject data folder and get files
% cd(rDir);
% d=dir('sj*');
% cd ..

if runInParallel
thisFunction = 'model_getSingleTrials.m';
s = parcluster;
s.ResourceTemplate='-l nodes=^N^:ppn=4,mem=16GB'; % EDITED ppn 4 to 1 and mem 7 to 16
job=createJob(s,'Name','Tom_Job');
job.AttachedFiles = {thisFunction};
end

for iSub =1:length(subjects)
    sjNum=subjects(iSub);
    for thisSession=1:2
        disp(['Processing ' sjNum])
        if runInParallel
            job.createTask(@model_getSingleTrials,0,{sjNum,thisSession})
        else
            model_getSingleTrials(sjNum,thisSession)
        end
    end
end

if runInParallel
    job.submit
end