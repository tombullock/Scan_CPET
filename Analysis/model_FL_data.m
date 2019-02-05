%{
model_FL_data
Author: Tom Bullock (adapted from Tyler Santander scripts)
Date: 07.17.18

Note: 
1)this works, but I'd prefer to not use michelle's hacked batch mat
2) using FIR instead of canonical?
3) should I be using rwls here for FL if I'm not using it for main stuff
(single trial)?

%}

function model_FL_data(sjNum)


%% add analysis scripts folder to path
addpath(genpath('/home/bullock/Scan_CPET/Analysis'))
%spm_rmpath
addpath /home/bullock/spm12

%% load defaults (good practice)
spm_get_defaults;

%% set dirs (*)
rootDir = '/home/bullock/Scan_CPET';
batchFilePath = '/home/bullock/Scan_CPET/Batch_Files';
    
%% loop through both blocks
for thisSession=1:2
    
    if thisSession==1
        sessionID='FL_b1';
    else
        sessionID='FL_b2';
    end
  
    %% set MRI data path
    mrDataPath = [rootDir '/' 'Subject_Data' '/' 'sj' num2str(sjNum) '/' 'data.functional.' sessionID ];
    trialData = '/home/bullock/Scan_CPET/Trial_Mats/FL_Data_Processed'; % preprocessed trial data    
    mkdir([rootDir '/' 'Subject_Data' '/' 'sj' num2str(sjNum) '/' 'data.groupedTrial.FL_all']);
    destDir = [rootDir '/' 'Subject_Data' '/' 'sj' num2str(sjNum) '/' 'data.groupedTrial.FL_all'];
    
    %% load the trialData
    %load([trialData '/' sprintf('sj%d_se%02d_trialMat_for_SPM.mat',sjNum,thisSession)]);
    load([trialData '/' sprintf('sj%d_se%02d_Trial_Data_FL_SPM.mat',sjNum,thisSession)]);
    
    %% get list of pre-processed nii files in the dir
    d=dir([mrDataPath '/' 'uf*']);
    for i=1:length(d)
        thisNii(i,:) = [mrDataPath '/' d(i).name ',1']; % why the ',1' needed?
    end
    
    %% tell matlab where to save spm file, betas and resids
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.dir={destDir};
    
    %% clear scans and then add scans to struct
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).scans={};
    files=thisNii;
    for file = 1:size(files,1)
        matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).scans{file,1} = thisNii(file,:);
    end
    
    %% model spec
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.timing.units = 'secs';
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.timing.RT = 0.7;
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.timing.fmri_t = 16;
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.timing.fmri_t0 = 8;
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).multi = {''};
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).multi_reg = {''};
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).hpf = 128;
    
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.bases.fir.length = 15;
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.bases.fir.order = 21;
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.volt = 1;
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.global = 'None';
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.mthresh = 0.8;
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.mask = {''};
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.cvi = 'wls';
    
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 1;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

    %% import condition onsets and durations from mat file into batch file
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(1).onset=allConds.loc1_onsets';
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(1).name='loc1';
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(1).duration= 5; % roughly
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(1).orth = 1;
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(1).tmod = 0;
    
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(2).onset=allConds.loc2_onsets';
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(2).name='loc2';
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(2).duration= 5;
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(2).orth = 1;
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(2).tmod = 0;
    
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(3).onset=allConds.loc3_onsets';
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(3).name='loc3';
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(3).duration= 5;
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(3).orth = 1;
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(3).tmod = 0;
    
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(4).onset=allConds.loc4_onsets';
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(4).name='loc4';
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(4).duration= 5;
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(4).orth = 1;
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(4).tmod = 0;
    
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(5).onset=allConds.loc5_onsets';
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(5).name='loc5';
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(5).duration= 5;
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(5).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(5).orth = 1;
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(5).tmod = 0;
    
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(6).onset=allConds.loc6_onsets';
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(6).name='loc6';
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(6).duration= 5;
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(6).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(6).orth = 1;
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(6).tmod = 0;
    
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(7).onset=allConds.loc7_onsets';
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(7).name='loc7';
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(7).duration= 5;
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(7).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(7).orth = 1;
    matlabbatch{1}.spm.tools.rwls.fmri_rwls_spec.sess(thisSession).cond(7).tmod = 0;
    
end
  
%% save "full" batch file
save([batchFilePath '/'  sprintf('sj%d_fullBatchFL.mat',sjNum)],'matlabbatch');
    


%% run batch job
spm_jobman('run',matlabbatch)

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


