%{
trialData_processMainTask

Author: Tom Bullock
Date: 05.24.18
%}

clear 
close all

%%sourceDir = '/Users/tombullock/Documents/Psychology/GABOR_VO2/Data';
%%saveDir = '/Users/tombullock/Documents/Psychology/GABOR_VO2/Data_For_MR';

sourceDir = '/Users/tombullock1/Desktop/GABOR_VO2/Data';
saveDir = '/Users/tombullock1/Desktop/GABOR_VO2/Data_For_MR';

sjNum = 133;

% load one datafile to get condition order
load([sourceDir '/' sprintf('ScanVO2_sj%d_se01_cd01_bl01.mat',sjNum)])
condOrder = trialLog.condOrder;
clear trialLog


% loop through files and create a structure with all four blocks in order
for iSession = 1:2 % pre/post
    
    % load one datafile to get first TR timing
    load([sourceDir '/' sprintf('ScanVO2_sj%d_se%02d_cd%02d_bl01.mat',sjNum,iSession,condOrder(1))])
    initialTR = trialLog.TRstarttimeLog;
    clear trialLog
    
    clear trialLog allTrialsMat allTrialsStruct allTrials
    cnt=0;
    for iCond = condOrder
        for iBlock = 1:2
            
            % load data
            load([sourceDir '/' sprintf('ScanVO2_sj%d_se%02d_cd%02d_bl%02d.mat',sjNum,iSession,iCond,iBlock)])           

            % add condition flag to trial structure
            for j=1:length(trialLog.trialInfo)
                trialLog.trialInfo(j).thisCond = trialLog.thisCondition;
            end
            
            % add target flag to trial structure (if repetition)
            for j=1:length(trialLog.trialInfo)-1
                if j==1
                    trialLog.trialInfo(j).target=0; % first trial is never a target
                end
                if trialLog.trialInfo(j).ori==trialLog.trialInfo(j+1).ori
                    trialLog.trialInfo(j+1).target=1;
                else
                    trialLog.trialInfo(j+1).target=0;
                end
            end
            
            % add response accuracy to trial structure
            for j=1:length(trialLog.trialInfo)-1
                
                if j==length(trialLog.trialInfo)-1
                    trialLog.trialInfo(j+1).targetHit=99; % first trial is never a target
                    trialLog.trialInfo(j+1).hitRT=99;
                end
               
                if trialLog.trialInfo(j).target==1 
                    if trialLog.trialInfo(j).resp~=-1 ||trialLog.trialInfo(j+1).resp~=-1
                        trialLog.trialInfo(j).targetHit=1; % hit
                        trialLog.trialInfo(j).hitRT= max([trialLog.trialInfo(j).RT,trialLog.trialInfo(j+1).RT]); % find correct RT (sometimes keypress transcends two trials, largest RT is correct)
                    else
                        trialLog.trialInfo(j).targetHit=0; % miss
                        trialLog.trialInfo(j).hitRT=99;
                    end
                else
                    trialLog.trialInfo(j).targetHit=99; % n/a
                    trialLog.trialInfo(j).hitRT=99;
                end
                
            end
            
            cnt=cnt+1;
            allTrials(cnt,:) = trialLog.trialInfo;
            theseConds(cnt) = iCond;
             
        end
    end
    
    % collate all structs into a single struct
    allTrialsStruct = [allTrials(1,:), allTrials(2,:), allTrials(3,:), allTrials(4,:)];
    
    for i=1:length(allTrialsStruct)
    
        allTrialsMat(i,:) = [...
            allTrialsStruct(i).thisCond,...
            allTrialsStruct(i).stimOnset - initialTR, ...
            allTrialsStruct(i).isiOnset - initialTR,...
            allTrialsStruct(i).isiOnset - allTrialsStruct(i).stimOnset,...            
            allTrialsStruct(i).ori,...
            allTrialsStruct(i).loc,...
            allTrialsStruct(i).target,...
            allTrialsStruct(i).targetHit,...
            allTrialsStruct(i).hitRT];
              
    end
    
    % column names
    colNames = {'cond(1loc2ori)','stimOnset','isiOnset','stimDuration','ori','loc','target','targetHit','hitRT'};
    
    save([saveDir '/' sprintf('sj%d_se%02d_VO2scan_for_MR.mat',sjNum,iSession)],'allTrialsMat','colNames')
 
end

clear all
close all