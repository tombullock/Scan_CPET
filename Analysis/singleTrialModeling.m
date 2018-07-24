%{
singleTrialModeling
Author: Tom Bullock (adapted from Tyler Santander scripts)
Date: 07.17.18

%}

function singleTrialModeling(sjNum,thisSession)



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
    sessionID='task_pre';
else
    sessionID='task_post';
end

%% TEMP
iRun=1;

%% load defaults (good practice)
spm_get_defaults;

% set dirs (*)
rootDir = '/home/bullock/Scan_CPET';

mrDataPath = [rootDir '/' 'Subject_Data' '/' 'sj' num2str(sjNum) '/' 'data.functional.' sessionID ];

%subjectDir = '/Users/tombullock/Documents/Psychology/GABOR_VO2_ANALYSIS/sj127_RAW/epi_mb_3x3x3_400TR_Gra_Physio_0003';
%mrDataPath = sprintf('/Users/tombullock/Documents/Psychology/GABOR_VO2_ANALYSIS/sj127_RAW/epi_mb_3x3x3_400TR_Gra_Physio_000%d',thisSession*3); % preprocessed MR data
trialData = '/home/bullock/Scan_CPET/Trial_Data'; % preprocessed trial data
dataDir = mrDataPath;

mkdir([rootDir '/' 'Subject_Data' '/' 'sj' num2str(sjNum) '/' 'data.singleTrial.' sessionID]);
destDir = [rootDir '/' 'Subject_Data' '/' 'sj' num2str(sjNum) '/' 'data.singleTrial.' sessionID];

% % get trial onsets/durations for this run.
% fileID = strcat([subjectDir '/data.behavior/'], spm_select('List', [subjectDir '/data.behavior/'], ['^' subID '-run' num2str(iRun) '.mat$']));
% [review, comp, prose, errors] = csfMRI_getBlockOnsets(fileID);

%% load the trialData
%load([trialData '/' sprintf('sj%d_se%02d_trialMat_for_SPM.mat',sjNum,thisSession)]);
load([trialData '/' sprintf('sj%d_se%02d_VO2scan_for_MR.mat',sjNum,thisSession)]);

%% get list of pre-processed nii files in the dir
d=dir([mrDataPath '/' 'uf*']);
for i=1:length(d)
    thisNii(i,:) = [mrDataPath '/' d(i).name ',1']; % why the ',1' needed?
end


% loop through trials for this run
for iTrial = 1:length(allTrialsMat)
    
    fprintf('====== PROCESSSING TRIAL %d of %d ======',iTrial,length(allTrialsMat))
    
    % get basic batch inputs
    matlabbatch = csfMRI_initializeDesign(sjNum,rootDir); %csfMRI_initializeDesign;
    
    % Onset/duration for this trial.
    trialOn  = allTrialsMat(iTrial,2); % onset
    trialOff = allTrialsMat(iTrial,4); % duration
    
    % Collect onsets/durations for ALL other trials.
    tempO = allTrialsMat(1:end ~= iTrial,2);
    tempD = allTrialsMat(1:end ~= iTrial,4);
    
    % Sort in time % IS THIS NECESSARY???
    [nuisanceOn, index] = sort(tempO);
    nuisanceOff         = tempD(index);
    
    % Construct regressors.
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).name     = 'Event';
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).onset    = trialOn;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).duration = trialOff;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).tmod     = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).pmod     = struct('name',{},'param',{},'poly',{});
    
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).name     = 'Nuisance';
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).onset    = nuisanceOn;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).duration = nuisanceOff;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).tmod     = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).pmod     = struct('name',{},'param',{},'poly',{});
    
    %     % Create a directory to store this model. ***MAKE A RESULTDS DIR AT
    %     TOP
    %     mkdir(['results.glm.reviewBeta' num2str(iRun) '-' num2str(iTrial)]);
    %     cd(['results.glm.reviewBeta' num2str(iRun) '-' num2str(iTrial)]);
    %resultsDir = pwd;
    %resultsDir = '/Users/tombullock/Documents/Psychology/GABOR_VO2_ANALYSIS/sj127_RAW/glmResults';
    
    %cd '/Users/tombullock/Documents/Psychology/GABOR_VO2_ANALYSIS/sj127_RAW/glmResults';
    % CD to destDir
    cd(destDir)
    
    % Grab the scans and specify/estimate the model.
    scans = thisNii;
    
    % TYLER CODE
    %scans = strcat([subjectDir '/' dataDir '/'], spm_select('List', ['../' dataDir], '^wuf.*nii$'));
    
    matlabbatch{1}.spm.stats.fmri_spec.sess.scans = cellstr(scans);
    matlabbatch{1}.spm.stats.fmri_spec.dir        = cellstr(destDir);
    
    spm_jobman('run', matlabbatch);
    
    csfMRI_estimateDesign(destDir);
    
    % delete the SPM.mat (not needed, will make spm pop up GUI window)
    delete('SPM.mat')
    
    % rename the 1st beta file (this is all we really need to save)
    movefile('beta_0001.nii',sprintf('trial%d_beta.nii',iTrial))
    
    cd ..
    
end % iTrial loop

%end % thisSession loop

%end % subject loop

end %function




% ----------------------------------------------------------------------- %
% BEGIN SUBROUTINES
% ----------------------------------------------------------------------- %

function matlabbatch = csfMRI_initializeDesign(sjNum,rootDir)
    
    spm('defaults','FMRI');
    warning off MATLAB:FINITE:obsoleteFunction;
    spm_jobman('initcfg');
    
    matlabbatch = {};

    matlabbatch{1}.spm.stats.fmri_spec.timing.units     = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT        = .4;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t    = 16;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0   = 8; 

    % IS THIS CORRECT?
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi       = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess.regress     = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg   = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess.hpf         = 128;

    % IS THIS CORRECT/NECESSARY?
    matlabbatch{1}.spm.stats.fmri_spec.fact             = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt             = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global           = 'None';
    %%matlabbatch{1}.spm.stats.fmri_spec.mask             = cellstr(['/Users/tombullock/Documents/Psychology/GABOR_VO2_ANALYSIS/sj127_RAW/hiRes/brainmask.nii']);
    matlabbatch{1}.spm.stats.fmri_spec.mask             = cellstr([rootDir '/' 'Subject_Data' '/' 'sj' num2str(sjNum) '/' 'data.anatomical.mask' '/' 'brainmask.nii']);
    matlabbatch{1}.spm.stats.fmri_spec.cvi              = 'AR(1)';

end

function csfMRI_estimateDesign(destDir)

    matlabbatch = {};

    %matlabbatch{1}.spm.stats.fmri_est.spmmat           = cellstr(strcat([pwd '/'], spm_select('List', pwd, '^SPM.*mat$')));
    %matlabbatch{1}.spm.stats.fmri_est.spmmat = cellstr(['/Users/tombullock/Documents/Psychology/GABOR_VO2_ANALYSIS/sj127_RAW/glmResults' '/' 'SPM.mat']);
    matlabbatch{1}.spm.stats.fmri_est.spmmat = cellstr([destDir '/' 'SPM.mat']);
    matlabbatch{1}.spm.stats.fmri_est.method.Classical = 1;

    spm_jobman('run', matlabbatch);

end

% ----------------------------------------------------------------------- %
% END SUBROUTINES
% ----------------------------------------------------------------------- %