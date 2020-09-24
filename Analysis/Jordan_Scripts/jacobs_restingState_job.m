function jacobs_restingState_job

%% Settings
s = parcluster;
s.ResourceTemplate='-l nodes=^N^:ppn=4,mem=16GB';
job=createJob(s,'Name','Tom_Job');
job.AttachedFiles = {'jacobs28andMe_restingState_Jordan.m'};

subjects = [107,109,111,112,113,115,116,119,121,124,125,127,130,133,135]; %101,103

%% Job
for iSub = 1:length(subjects)
    for iSess = 1:2
        sjNum = subjects(iSub);
        %jacobs28andMe_restingState_Jordan(sjNum,iSess)
        job.createTask(@jacobs28andMe_restingState_Jordan,0,{sjNum,iSess});
    end
end

job.submit
wait(job,'finished')
%results = getAllOutputArguments(job);
end
