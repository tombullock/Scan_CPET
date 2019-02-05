%{
model_groupData
Author: Tom Bullock (adapted from Tyler Santander scripts)
Date: 12.21.18

This script allows me to contrast ori vs. loc within a single session (i.e.
within "pre" or "post"...BUT does not allow me to contrast across sessions
(e.g. Pre vs. Post ...see other script for that)

%}

function model_visHRF_singleSession(sjNum,thisSession)


%% add analysis scripts folder to path
addpath(genpath('/home/bullock/Scan_CPET/Analysis'))
%spm_rmpath
addpath(genpath('/home/bullock/spm12'))

%% load defaults (good practice)
spm_get_defaults;

%% set dirs (*)
rootDir = '/home/bullock/Scan_CPET';
batchFilePath = '/home/bullock/Scan_CPET/Batch_Files';

%% set session ID

if thisSession==1
    sessionID='task_pre';
else
    sessionID='task_post';
end

%% set MRI data path
mrDataPath = [rootDir '/' 'Subject_Data' '/' 'sj' num2str(sjNum) '/' 'data.functional.' sessionID ];
trialData = '/home/bullock/Scan_CPET/Trial_Mats/Trial_Data_Processed_Grouped'; % preprocessed trial data
mkdir([rootDir '/' 'Subject_Data' '/' 'sj' num2str(sjNum) '/' 'data.groupedTrial.' sessionID]);
destDir = [rootDir '/' 'Subject_Data' '/' 'sj' num2str(sjNum) '/' 'data.groupedTrial.' sessionID];


%% load the trialData
load([trialData '/' sprintf('sj%d_se%02d_trialMat_for_SPM.mat',sjNum,thisSession)]);

%% get list of pre-processed nii files in the dir
d=dir([mrDataPath '/' 'uf*']);
for i=1:length(d)
    thisNii(i,:) = [mrDataPath '/' d(i).name ',1']; % why the ',1' needed?
end

%% tell matlab where to save spm file, betas and resids
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.dir={destDir};

%% clear scans and then add scans to struct
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(1).scans={};
files=thisNii;
for file = 1:size(files,1)
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(1).scans{file,1} = thisNii(file,:);
end

%% model spec
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.timing.units = 'secs';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.timing.RT = 0.4; % 400 ms TR
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.timing.fmri_t0 = 8;
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(1).multi = {''};
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(1).regress = struct('name', {}, 'val', {});
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(1).multi_reg = {''};
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(1).hpf = 128;

matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.bases.fir.length = 12; % 12 second window
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.bases.fir.order = 30; % 30 basis functions in this window (12/.4 = 30)
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.volt = 1;
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.global = 'None';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.mthresh = 0.8;
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.mask = {''};
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.cvi = 'wls';

matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 1;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

%% import condition onsets and durations from mat file into batch file
for i=1:12
    if      i==1;   thisOnset = allConds.loc1_onsets'; thisName = 'loc1';
    elseif  i==2;   thisOnset = allConds.loc2_onsets'; thisName = 'loc2';
    elseif  i==3;   thisOnset = allConds.loc3_onsets'; thisName = 'loc3';
    elseif  i==4;   thisOnset = allConds.loc4_onsets'; thisName = 'loc4';
    elseif  i==5;   thisOnset = allConds.loc5_onsets'; thisName = 'loc5';
    elseif  i==6;   thisOnset = allConds.loc6_onsets'; thisName = 'loc6';
    elseif  i==7;   thisOnset = allConds.ori1_onsets'; thisName = 'ori1';
    elseif  i==8;   thisOnset = allConds.ori2_onsets'; thisName = 'ori2';
    elseif  i==9;   thisOnset = allConds.ori3_onsets'; thisName = 'ori3';
    elseif  i==10;  thisOnset = allConds.ori4_onsets'; thisName = 'ori4';
    elseif  i==11;  thisOnset = allConds.ori5_onsets'; thisName = 'ori5';
    elseif  i==12;  thisOnset = allConds.ori6_onsets'; thisName = 'ori6';
    end
    
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(1).cond(i).onset=thisOnset;
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(1).cond(i).name=thisName;
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(1).cond(i).duration= .5; % roughly
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(1).cond(i).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(1).cond(i).orth = 1;
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(1).cond(i).tmod = 0;
end

%% save "full" batch file
save([batchFilePath '/'  sprintf('sj%d_se%02d_fullBatch_vis_group.mat',sjNum,thisSession)],'matlabbatch');


%% run batch job
spm_jobman('run',matlabbatch)

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%
% % loop through trials for this run
% for iTrial = 1:length(allTrialsMat)
%
%     fprintf('====== PROCESSSING TRIAL %d of %d ======',iTrial,length(allTrialsMat))
%
%     % get basic batch inputs
%     matlabbatch = csfMRI_initializeDesign(sjNum,rootDir); %csfMRI_initializeDesign;
%
%     % Onset/duration for this trial.
%     trialOn  = allTrialsMat(iTrial,2); % onset
%     trialOff = allTrialsMat(iTrial,4); % duration
%
%     % Collect onsets/durations for ALL other trials.
%     tempO = allTrialsMat(1:end ~= iTrial,2);
%     tempD = allTrialsMat(1:end ~= iTrial,4);
%
%     % Sort in time % IS THIS NECESSARY???
%     [nuisanceOn, index] = sort(tempO);
%     nuisanceOff         = tempD(index);
%
%     % Construct regressors.
%     matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).name     = 'Event';
%     matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).onset    = trialOn;
%     matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).duration = trialOff;
%     matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).tmod     = 0;
%     matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).pmod     = struct('name',{},'param',{},'poly',{});
%
%     matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).name     = 'Nuisance';
%     matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).onset    = nuisanceOn;
%     matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).duration = nuisanceOff;
%     matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).tmod     = 0;
%     matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).pmod     = struct('name',{},'param',{},'poly',{});
%
%     %     % Create a directory to store this model. ***MAKE A RESULTDS DIR AT
%     %     TOP
%     %     mkdir(['results.glm.reviewBeta' num2str(iRun) '-' num2str(iTrial)]);
%     %     cd(['results.glm.reviewBeta' num2str(iRun) '-' num2str(iTrial)]);
%     %resultsDir = pwd;
%     %resultsDir = '/Users/tombullock/Documents/Psychology/GABOR_VO2_ANALYSIS/sj127_RAW/glmResults';
%
%     %cd '/Users/tombullock/Documents/Psychology/GABOR_VO2_ANALYSIS/sj127_RAW/glmResults';
%     % CD to destDir
%     cd(destDir)
%
%     % Grab the scans and specify/estimate the model.
%     scans = thisNii;
%
%     % TYLER CODE
%     %scans = strcat([subjectDir '/' dataDir '/'], spm_select('List', ['../' dataDir], '^wuf.*nii$'));
%
%     matlabbatch{1}.spm.stats.fmri_spec.sess.scans = cellstr(scans);
%     matlabbatch{1}.spm.stats.fmri_spec.dir        = cellstr(destDir);
%
%     spm_jobman('run', matlabbatch);
%
%     csfMRI_estimateDesign(destDir);
%
%     % delete the SPM.mat (not needed, will make spm pop up GUI window)
%     delete('SPM.mat')
%
%     % rename the 1st beta file (this is all we really need to save)
%     movefile('beta_0001.nii',sprintf('trial%d_beta.nii',iTrial))
%
%     cd ..
%
% end % iTrial loop
%
% %end % thisSession loop
%
% %end % subject loop
%
% end %function




% % ----------------------------------------------------------------------- %
% % BEGIN SUBROUTINES
% % ----------------------------------------------------------------------- %
%
% function matlabbatch = csfMRI_initializeDesign(sjNum,rootDir)
%
%     spm('defaults','FMRI');
%     warning off MATLAB:FINITE:obsoleteFunction;
%     spm_jobman('initcfg');
%
%     matlabbatch = {};
%
%     matlabbatch{1}.spm.stats.fmri_spec.timing.units     = 'secs';
%     matlabbatch{1}.spm.stats.fmri_spec.timing.RT        = .4;
%     matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t    = 16;
%     matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0   = 8;
%
%     % IS THIS CORRECT?
%     matlabbatch{1}.spm.stats.fmri_spec.sess.multi       = {''};
%     matlabbatch{1}.spm.stats.fmri_spec.sess.regress     = struct('name', {}, 'val', {});
%     matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg   = {''};
%     matlabbatch{1}.spm.stats.fmri_spec.sess.hpf         = 128;
%
%     % IS THIS CORRECT/NECESSARY?
%     matlabbatch{1}.spm.stats.fmri_spec.fact             = struct('name', {}, 'levels', {});
%     matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
%     matlabbatch{1}.spm.stats.fmri_spec.volt             = 1;
%     matlabbatch{1}.spm.stats.fmri_spec.global           = 'None';
%     %%matlabbatch{1}.spm.stats.fmri_spec.mask             = cellstr(['/Users/tombullock/Documents/Psychology/GABOR_VO2_ANALYSIS/sj127_RAW/hiRes/brainmask.nii']);
%     matlabbatch{1}.spm.stats.fmri_spec.mask             = cellstr([rootDir '/' 'Subject_Data' '/' 'sj' num2str(sjNum) '/' 'data.anatomical.mask' '/' 'brainmask.nii']);
%     matlabbatch{1}.spm.stats.fmri_spec.cvi              = 'AR(1)';
%
% end
%
% function csfMRI_estimateDesign(destDir)
%
%     matlabbatch = {};
%
%     %matlabbatch{1}.spm.stats.fmri_est.spmmat           = cellstr(strcat([pwd '/'], spm_select('List', pwd, '^SPM.*mat$')));
%     %matlabbatch{1}.spm.stats.fmri_est.spmmat = cellstr(['/Users/tombullock/Documents/Psychology/GABOR_VO2_ANALYSIS/sj127_RAW/glmResults' '/' 'SPM.mat']);
%     matlabbatch{1}.spm.stats.fmri_est.spmmat = cellstr([destDir '/' 'SPM.mat']);
%     matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;
%
%     spm_jobman('run', matlabbatch);
%
% end
%
% % ----------------------------------------------------------------------- %
% % END SUBROUTINES
% % ----------------------------------------------------------------------- %