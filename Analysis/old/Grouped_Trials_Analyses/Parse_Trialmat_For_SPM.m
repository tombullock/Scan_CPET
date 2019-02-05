%{
Parse_Trialmat_For_SPM
Author: Tom Bullock, UCSB Attention Lab
Date: 06.12.18

Takes the MR data that I converted for Allison and converts to SPM Batch
friendly analysis
%}

clear all
close all

sjNum = 127;

% trialData dir
trialData = '/Users/tombullock/Documents/Psychology/GABOR_VO2_ANALYSIS/TrialMats';

% SPM trial mat destination dir
spmTrialData = '/Users/tombullock/Documents/Psychology/GABOR_VO2_ANALYSIS/TrialMats_SPM';

for iSession=1:2
    
    allConds = []; allTrialsMat = [];
    
    % load the trialData
    load([trialData '/' sprintf('sj%d_se%02d_VO2scan_for_MR.mat',sjNum,iSession)]);
    
    % parse into conditions (cond1=loc,cond2=ori, col5=ori,col6=loc)
    loc1_cnt=0;loc2_cnt=0;loc3_cnt=0;loc4_cnt=0;loc5_cnt=0;loc6_cnt=0;
    for iTrial=1:size(allTrialsMat,1)
        if allTrialsMat(iTrial,1)==1 && allTrialsMat(iTrial,7)~=1 % if loc cond & not a targ repeat
            if allTrialsMat(iTrial,6)==1
                loc1_cnt=loc1_cnt+1;
                allConds.loc1_onsets(loc1_cnt) = allTrialsMat(iTrial,2);
                allConds.loc1_durs(loc1_cnt) = allTrialsMat(iTrial,4);
            elseif allTrialsMat(iTrial,6)==2
                loc2_cnt=loc2_cnt+1;
                allConds.loc2_onsets(loc2_cnt) = allTrialsMat(iTrial,2);
                allConds.loc2_durs(loc2_cnt) = allTrialsMat(iTrial,4);
            elseif allTrialsMat(iTrial,6)==3
                loc3_cnt=loc3_cnt+1;
                allConds.loc3_onsets(loc3_cnt) = allTrialsMat(iTrial,2);
                allConds.loc3_durs(loc3_cnt) = allTrialsMat(iTrial,4);
            elseif allTrialsMat(iTrial,6)==4
                loc4_cnt=loc4_cnt+1;
                allConds.loc4_onsets(loc4_cnt) = allTrialsMat(iTrial,2);
                allConds.loc4_durs(loc4_cnt) = allTrialsMat(iTrial,4);
            elseif allTrialsMat(iTrial,6)==5
                loc5_cnt=loc5_cnt+1;
                allConds.loc5_onsets(loc5_cnt) = allTrialsMat(iTrial,2);
                allConds.loc5_durs(loc5_cnt) = allTrialsMat(iTrial,4);
            elseif allTrialsMat(iTrial,6)==6
                loc6_cnt=loc6_cnt+1;
                allConds.loc6_onsets(loc6_cnt) = allTrialsMat(iTrial,2);
                allConds.loc6_durs(loc6_cnt) = allTrialsMat(iTrial,4);
            end
        end
    end
    
    % parse into conditions (cond1=loc,cond2=ori, col5=ori,col6=loc)
    ori1_cnt=0;ori2_cnt=0;ori3_cnt=0;ori4_cnt=0;ori5_cnt=0;ori6_cnt=0;
    for iTrial=1:size(allTrialsMat,1)
        if allTrialsMat(iTrial,1)==2 && allTrialsMat(iTrial,7)~=1; % if ori cond & not a targ repeat
            if allTrialsMat(iTrial,5)==1
                ori1_cnt=ori1_cnt+1;
                allConds.ori1_onsets(ori1_cnt) = allTrialsMat(iTrial,2);
                allConds.ori1_durs(ori1_cnt) = allTrialsMat(iTrial,4);
            elseif allTrialsMat(iTrial,5)==2
                ori2_cnt=ori2_cnt+1;
                allConds.ori2_onsets(ori2_cnt) = allTrialsMat(iTrial,2);
                allConds.ori2_durs(ori2_cnt) = allTrialsMat(iTrial,4);
            elseif allTrialsMat(iTrial,5)==3
                ori3_cnt=ori3_cnt+1;
                allConds.ori3_onsets(ori3_cnt) = allTrialsMat(iTrial,2);
                allConds.ori3_durs(ori3_cnt) = allTrialsMat(iTrial,4);
            elseif allTrialsMat(iTrial,5)==4
                ori4_cnt=ori4_cnt+1;
                allConds.ori4_onsets(ori4_cnt) = allTrialsMat(iTrial,2);
                allConds.ori4_durs(ori4_cnt) = allTrialsMat(iTrial,4);
            elseif allTrialsMat(iTrial,5)==5
                ori5_cnt=ori5_cnt+1;
                allConds.ori5_onsets(ori5_cnt) = allTrialsMat(iTrial,2);
                allConds.ori5_durs(ori5_cnt) = allTrialsMat(iTrial,4);
            elseif allTrialsMat(iTrial,5)==6
                ori6_cnt=ori6_cnt+1;
                allConds.ori6_onsets(ori6_cnt) = allTrialsMat(iTrial,2);
                allConds.ori6_durs(ori6_cnt) = allTrialsMat(iTrial,4);
            end
        end
    end
    
    % save parsed data
    save([spmTrialData '/' sprintf('sj%d_se%02d_trialMat_for_SPM.mat',sjNum,iSession)],'allConds','allTrialsMat')
    
end

clear


%     %get condition onsets and durations from mat file
% matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(1).onset=load_ul_lo;
% matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(1).name='load_ul_lo';
% matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(1).duration= 0;
% matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
%     
    