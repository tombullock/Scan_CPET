%{
CREATE_MRI_DESIGN_MATRIX
Author: Tom Bullock, UCSB Attention Lab
Date: 07.17.18

NOTE: check that the pre VO2max session is "0003" and post VO2max is "0006"
 127 "post" is not pre-processed yet...don't run

HOW SO I SAVE THE SPM FILE AS SOMETHING UNIQUE?  Do I save to a separate
folder for each subject?

%% MAKE EACH TRIAL A CONDITION, KEEP DESIGN MATRIX THE SAME etc. %%

%}

clear 
close all

%% which subject and run (i.e. pre vs. post VO2)
sjNum=127;
thisSession = 1; % 1= pre VO2max, 2=post VO2max

%% load defaults (good practice)
spm_get_defaults;

%% start by adding the path where the batch.mat file lives. 
addpath('/Users/tombullock/Documents/Psychology/GABOR_VO2_ANALYSIS/Batch')
batchFilePath = '/Users/tombullock/Documents/Psychology/GABOR_VO2_ANALYSIS/Batch'; % batch file with some stuff already entered
mrDataPath = sprintf('/Users/tombullock/Documents/Psychology/GABOR_VO2_ANALYSIS/sj127_RAW/epi_mb_3x3x3_400TR_Gra_Physio_000%d',thisSession*3); % preprocessed MR data
trialData = '/Users/tombullock/Documents/Psychology/GABOR_VO2_ANALYSIS/TrialMats_SPM'; % preprocessed trial data
processedData = '/Users/tombullock/Documents/Psychology/GABOR_VO2_ANALYSIS/Processed_SPM'; % SPM data folder

%% load the trialData 
load([trialData '/' sprintf('sj%d_se%02d_trialMat_for_SPM.mat',sjNum,thisSession)]);

%% load an empty batch file (except for basic info on directories, TRs etc.)
load([batchFilePath '/' 'basicBATCH.mat']) 

%% get list of pre-processed nii files in the dir
d=dir([mrDataPath '/' 'uf*']);
for i=1:length(d)
    thisNii(i,:) = [mrDataPath '/' d(i).name ',1']; % why the ',1' needed?
end

% %% get list of nii files in dir (spm method for above...brings up gui)
% thisNii = spm_select(Inf,'image','Select nii files', '', mrDataPath,...
%     '.*uf',1:10000);

%% tell matlab where to save spm file, betas and resids
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.dir={processedData};

%% clear scans and then add scans to struct
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.scans={};
files=thisNii;    
for file = 1:size(files,1)
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.scans{file,1} = thisNii(file,:);
end


%% import condition onsets and durations from mat file into batch file
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(1).onset=allConds.loc1_onsets';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(1).name='loc1';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(1).duration= .5; % roughly
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(2).onset=allConds.loc2_onsets';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(2).name='loc2';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(2).duration= .5; 
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(3).onset=allConds.loc3_onsets';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(3).name='loc3';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(3).duration= .5; 
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(4).onset=allConds.loc4_onsets';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(4).name='loc4';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(4).duration= .5; 
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(5).onset=allConds.loc5_onsets';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(5).name='loc5';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(5).duration= .5; 
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(5).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(6).onset=allConds.loc6_onsets';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(6).name='loc6';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(6).duration= .5;
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(6).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(7).onset=allConds.ori1_onsets';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(7).name='ori1';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(7).duration= .5; % roughly
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(7).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(8).onset=allConds.ori2_onsets';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(8).name='ori2';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(8).duration= .5; 
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(8).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(9).onset=allConds.ori3_onsets';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(9).name='ori3';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(9).duration= .5; 
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(9).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(10).onset=allConds.ori4_onsets';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(10).name='ori4';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(10).duration= .5; 
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(10).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(11).onset=allConds.ori5_onsets';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(11).name='ori5';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(11).duration= .5; 
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(11).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(12).onset=allConds.ori6_onsets';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(12).name='ori6';
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(12).duration= .5;
matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess.cond(12).pmod = struct('name', {}, 'param', {}, 'poly', {});

%% save "full" batch file
save([batchFilePath '/'  sprintf('%d%s_fullBatch.mat',sjNum,thisSession)],'matlabbatch');

%% run batch job
spm_jobman('run',matlabbatch);
