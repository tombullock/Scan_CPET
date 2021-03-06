%{
model_groupData_job
Author: Tom Bullock
Date: 20.12.18
 
%}

% clear 
% close all

subjects = [101,103,107,109,111,112,113,119,121,125,127,130,133,135];
%subjects = 107;



% define directory with subject data
%%rDir = '/home/bullock/Scan_CPET/Subject_Data';

% add analysis scripts folder to path
addpath(genpath('/home/bullock/Scan_CPET/Analysis'))

%% run in parallel
runInParallel = 0;

% % cd to subject data folder and get files
% cd(rDir);
% d=dir('sj*');
% cd ..

if runInParallel
thisFunction = 'model_visHRF_bothSessions.m';
s = parcluster;
s.ResourceTemplate='-l nodes=^N^:ppn=4,mem=7GB';
job=createJob(s,'Name','Tom_Job');
job.AttachedFiles = {thisFunction};
end

for iSub =1:length(subjects)
    sjNum=subjects(iSub);
    disp(['Processing ' num2str(sjNum)])
    if runInParallel
        job.createTask(@model_visHRF_bothSessions,0,{sjNum})
    else
        model_visHRF_bothSessions(sjNum)
    end 
end

if runInParallel
    job.submit
end