%{
trialData_processMainTask_FL

Author: Tom Bullock
Date: 05.24.18

Group trials by location

%}

clear 
close all

sourceDir = '/home/bullock/Scan_CPET/Trial_Mats/FL_Data_Raw';
saveDir = '/home/bullock/Scan_CPET/Trial_Mats/FL_Data_Processed';

cd(sourceDir)
d = dir('Localizer*.mat');

for iLoop=1:length(d)
    
    allConds = [];sjNum=[];thisBlock=[];
    
    % load datafile
    load(d(iLoop).name)
    
    loc1_cnt=0; loc2_cnt=0; loc3_cnt=0; loc4_cnt=0; loc5_cnt=0; loc6_cnt=0; loc7_cnt=0;
    
    % loop through trialLog
    for iTrial=1:length(trialLog.trialInfo)
        
        if trialLog.trialInfo(iTrial).loc==1
            loc1_cnt=loc1_cnt+1;
            allConds.loc1_stimCode(loc1_cnt)=trialLog.trialInfo(iTrial).loc;
            allConds.loc1_onsets(loc1_cnt)=trialLog.trialInfo(iTrial).stimOnsetTR;
            allConds.loc1_durs(loc1_cnt)=trialLog.trialInfo(iTrial).stimDuration;
        elseif trialLog.trialInfo(iTrial).loc==2
            loc2_cnt=loc2_cnt+1;
            allConds.loc2_stimCode(loc2_cnt)=trialLog.trialInfo(iTrial).loc;
            allConds.loc2_onsets(loc2_cnt)=trialLog.trialInfo(iTrial).stimOnsetTR;
            allConds.loc2_durs(loc2_cnt)=trialLog.trialInfo(iTrial).stimDuration;
        elseif trialLog.trialInfo(iTrial).loc==3
            loc3_cnt=loc3_cnt+1;
            allConds.loc3_stimCode(loc3_cnt)=trialLog.trialInfo(iTrial).loc;
            allConds.loc3_onsets(loc3_cnt)=trialLog.trialInfo(iTrial).stimOnsetTR;
            allConds.loc3_durs(loc3_cnt)=trialLog.trialInfo(iTrial).stimDuration;
        elseif trialLog.trialInfo(iTrial).loc==4
            loc4_cnt=loc4_cnt+1;
            allConds.loc4_stimCode(loc4_cnt)=trialLog.trialInfo(iTrial).loc;
            allConds.loc4_onsets(loc4_cnt)=trialLog.trialInfo(iTrial).stimOnsetTR;
            allConds.loc4_durs(loc4_cnt)=trialLog.trialInfo(iTrial).stimDuration;
        elseif trialLog.trialInfo(iTrial).loc==5
            loc5_cnt=loc5_cnt+1;
            allConds.loc5_stimCode(loc5_cnt)=trialLog.trialInfo(iTrial).loc;
            allConds.loc5_onsets(loc5_cnt)=trialLog.trialInfo(iTrial).stimOnsetTR;
            allConds.loc5_durs(loc5_cnt)=trialLog.trialInfo(iTrial).stimDuration;
        elseif trialLog.trialInfo(iTrial).loc==6
            loc6_cnt=loc6_cnt+1;
            allConds.loc6_stimCode(loc6_cnt)=trialLog.trialInfo(iTrial).loc;
            allConds.loc6_onsets(loc6_cnt)=trialLog.trialInfo(iTrial).stimOnsetTR;
            allConds.loc6_durs(loc6_cnt)=trialLog.trialInfo(iTrial).stimDuration;
        elseif trialLog.trialInfo(iTrial).loc==7
            loc7_cnt=loc7_cnt+1;
            allConds.loc7_stimCode(loc7_cnt)=trialLog.trialInfo(iTrial).loc;
            allConds.loc7_onsets(loc7_cnt)=trialLog.trialInfo(iTrial).stimOnsetTR;
            allConds.loc7_durs(loc7_cnt)=trialLog.trialInfo(iTrial).stimDuration;
        end
  
    end
    
    % save mats
    sjNum = str2double(d(iLoop).name(21:23)); thisBlock= str2double(d(iLoop).name(27:28));
    
    save([saveDir '/' sprintf('sj%d_se%02d_Trial_Data_FL_SPM.mat',sjNum,thisBlock)],'allConds','trialLog')
    
end

clear
close all



% % 
% % % loop through files and create a structure with all four blocks in order
% % for iSession = 1:2 % pre/post
% %     
% %     % load one datafile to get first TR timing
% %     load([sourceDir '/' sprintf('ScanVO2_sj%d_se%02d_cd%02d_bl01.mat',sjNum,iSession,condOrder(1))])
% %     initialTR = trialLog.TRstarttimeLog;
% %     clear trialLog
% %     
% %     clear trialLog allTrialsMat allTrialsStruct allTrials
% %     cnt=0;
% %     for iCond = condOrder
% %         for iBlock = 1:2
% %             
% %             % load data
% %             load([sourceDir '/' sprintf('ScanVO2_sj%d_se%02d_cd%02d_bl%02d.mat',sjNum,iSession,iCond,iBlock)])           
% % 
% %             % add condition flag to trial structure
% %             for j=1:length(trialLog.trialInfo)
% %                 trialLog.trialInfo(j).thisCond = trialLog.thisCondition;
% %             end
% %             
% %             % add target flag to trial structure (if repetition)
% %             for j=1:length(trialLog.trialInfo)-1
% %                 if j==1
% %                     trialLog.trialInfo(j).target=0; % first trial is never a target
% %                 end
% %                 if trialLog.trialInfo(j).ori==trialLog.trialInfo(j+1).ori
% %                     trialLog.trialInfo(j+1).target=1;
% %                 else
% %                     trialLog.trialInfo(j+1).target=0;
% %                 end
% %             end
% %             
% %             % add response accuracy to trial structure
% %             for j=1:length(trialLog.trialInfo)-1
% %                 
% %                 if j==length(trialLog.trialInfo)-1
% %                     trialLog.trialInfo(j+1).targetHit=99; % first trial is never a target
% %                     trialLog.trialInfo(j+1).hitRT=99;
% %                 end
% %                
% %                 if trialLog.trialInfo(j).target==1 
% %                     if trialLog.trialInfo(j).resp~=-1 ||trialLog.trialInfo(j+1).resp~=-1
% %                         trialLog.trialInfo(j).targetHit=1; % hit
% %                         trialLog.trialInfo(j).hitRT= max([trialLog.trialInfo(j).RT,trialLog.trialInfo(j+1).RT]); % find correct RT (sometimes keypress transcends two trials, largest RT is correct)
% %                     else
% %                         trialLog.trialInfo(j).targetHit=0; % miss
% %                         trialLog.trialInfo(j).hitRT=99;
% %                     end
% %                 else
% %                     trialLog.trialInfo(j).targetHit=99; % n/a
% %                     trialLog.trialInfo(j).hitRT=99;
% %                 end
% %                 
% %             end
% %             
% %             cnt=cnt+1;
% %             allTrials(cnt,:) = trialLog.trialInfo;
% %             theseConds(cnt) = iCond;
% %              
% %         end
% %     end
% %     
% %     % collate all structs into a single struct
% %     allTrialsStruct = [allTrials(1,:), allTrials(2,:), allTrials(3,:), allTrials(4,:)];
% %     
% %     for i=1:length(allTrialsStruct)
% %     
% %         allTrialsMat(i,:) = [...
% %             allTrialsStruct(i).thisCond,...
% %             allTrialsStruct(i).stimOnset - initialTR, ...
% %             allTrialsStruct(i).isiOnset - initialTR,...
% %             allTrialsStruct(i).isiOnset - allTrialsStruct(i).stimOnset,...            
% %             allTrialsStruct(i).ori,...
% %             allTrialsStruct(i).loc,...
% %             allTrialsStruct(i).target,...
% %             allTrialsStruct(i).targetHit,...
% %             allTrialsStruct(i).hitRT];
% %               
% %     end
% %     
% %     % column names
% %     colNames = {'cond(1loc2ori)','stimOnset','isiOnset','stimDuration','ori','loc','target','targetHit','hitRT'};
% %     
% %     save([saveDir '/' sprintf('sj%d_se%02d_VO2scan_for_MR.mat',sjNum,iSession)],'allTrialsMat','colNames')
% %  
% % end
% % 
% % clear all
% % close all