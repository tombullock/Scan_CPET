%{
singleTrialModeling
Author: Tom Bullock (adapted from Tyler Santander scripts)
Date: 07.17.18

Note: 
1)this works, but I'd prefer to not use michelle's hacked batch mat
2) using FIR instead of canonical?
3) should I be using rwls here for FL if I'm not using it for main stuff
(single trial)?

%}

function FL_modeling(sjNum,thisSession)



%% add analysis scripts folder to path
addpath(genpath('/home/bullock/Scan_CPET/Analysis'))
%spm_rmpath
addpath /home/bullock/spm12

%for iSub=1:1;%length(subjects)

%sjNum = subjects(iSub);

%for thisSession=1:2 % 1(pre), 2(post)

%% which subject and run (i.e. pre vs. post VO2)
%sjNum=127;
%thisSession = 1; % 1= pre VO2max, 2=post VO2max

if thisSession==1
    sessionID='FL_b1';
else
    sessionID='FL_b2';
end
% 
% %% TEMP
% iRun=1;

%% load defaults (good practice)
spm_get_defaults;

% set dirs (*)
rootDir = '/home/bullock/Scan_CPET';

mrDataPath = [rootDir '/' 'Subject_Data' '/' 'sj' num2str(sjNum) '/' 'data.functional.' sessionID ];

batchFilePath = '/home/bullock/Scan_CPET/Batch_Files';

%subjectDir = '/Users/tombullock/Documents/Psychology/GABOR_VO2_ANALYSIS/sj127_RAW/epi_mb_3x3x3_400TR_Gra_Physio_0003';
%mrDataPath = sprintf('/Users/tombullock/Documents/Psychology/GABOR_VO2_ANALYSIS/sj127_RAW/epi_mb_3x3x3_400TR_Gra_Physio_000%d',thisSession*3); % preprocessed MR data
trialData = '/home/bullock/Scan_CPET/Trial_Mats/FL_Data_Processed'; % preprocessed trial data
%dataDir = mrDataPath;

mkdir([rootDir '/' 'Subject_Data' '/' 'sj' num2str(sjNum) '/' 'data.groupedTrial.' sessionID]);
destDir = [rootDir '/' 'Subject_Data' '/' 'sj' num2str(sjNum) '/' 'data.groupedTrial.' sessionID];

% % get trial onsets/durations for this run.
% fileID = strcat([subjectDir '/data.behavior/'], spm_select('List', [subjectDir '/data.behavior/'], ['^' subID '-run' num2str(iRun) '.mat$']));
% [review, comp, prose, errors] = csfMRI_getBlockOnsets(fileID);

%% load the trialData
%load([trialData '/' sprintf('sj%d_se%02d_trialMat_for_SPM.mat',sjNum,thisSession)]);
load([trialData '/' sprintf('sj%d_se%02d_Trial_Data_FL_SPM.mat',sjNum,thisSession)]);

%% load michelle's basicBatch mat file (already contains model/stats stuff for rwls)
load([batchFilePath '/' 'basicBatch.mat'])

%% get list of pre-processed nii files in the dir
d=dir([mrDataPath '/' 'uf*']);
for i=1:length(d)
    thisNii(i,:) = [mrDataPath '/' d(i).name ',1']; % why the ',1' needed?
end

%%%%%

%% tell matlab where to save spm file, betas and resids
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.dir={destDir};

%% clear scans and then add scans to struct
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.scans={};
files=thisNii;    
for file = 1:size(files,1)
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.scans{file,1} = thisNii(file,:);
end

%% import condition onsets and durations from mat file into batch file
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(1).onset=allConds.loc1_onsets';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(1).name='loc1';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(1).duration= 5; % roughly
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(2).onset=allConds.loc2_onsets';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(2).name='loc2';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(2).duration= 5; 
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(3).onset=allConds.loc3_onsets';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(3).name='loc3';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(3).duration= 5; 
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(4).onset=allConds.loc4_onsets';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(4).name='loc4';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(4).duration= 5; 
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(5).onset=allConds.loc5_onsets';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(5).name='loc5';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(5).duration= 5; 
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(5).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(6).onset=allConds.loc6_onsets';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(6).name='loc6';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(6).duration= 5;
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(6).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(7).onset=allConds.loc7_onsets';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(7).name='loc7';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(7).duration= 5;
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(7).pmod = struct('name', {}, 'param', {}, 'poly', {});

%% save "full" batch file
save([batchFilePath '/'  sprintf('sj%d_se%02d_fullBatchFL.mat',sjNum,thisSession)],'matlabbatch');

%% run batch job
spm_jobman('run',matlabbatch)

end







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