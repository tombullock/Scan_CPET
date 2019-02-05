%{
compile_betas_FL
Author: Tom Bullock
Date: 07.26.18

Extract voxels from betas where the HRF is peaking (e.g. between ~ 3 and 6
secs).  15 betas per 7 locations, so 10.5 s period per stimulus (3.5 to 5.6
secs perhaps, then average across those).  THEN do contrasts, so subtract
all perhipherals from central?  THEN use active areas to constrain voxels
in main study (e.g. all 6 spatial locs for spatial CTFs, just central for
ori CTFs)

%}

function compile_betas_FL(sjNum)

addpath('/home/bullock/spm12')

trialMatDir = '/home/bullock/Scan_CPET/Trial_Mats/FL_Data_Raw';

for thisSession=1:2
    
    if thisSession==1
        sessionID = 'FL_b1';
    elseif thisSession==2
        sessionID = 'FL_b2';
    end
    
    saveDir = '/home/bullock/Scan_CPET/FL_Processed_Data';

    cd(['/home/bullock/Scan_CPET/Subject_Data' '/sj' num2str(sjNum) '/' 'data.groupedTrial.' sessionID])
    
    %%cd /Users/tombullock/Documents/Psychology/GABOR_VO2_ANALYSIS/sj127_RAW/glmResults
    
    % get all trial betas
    d=dir('beta*.nii');
    for iTrial=1:length(d)
        disp(['Processing Trial ' num2str(iTrial)])
        V = spm_vol(sprintf('./beta_%04d.nii',iTrial));      
        volume = spm_read_vols(V);
        voxelMat(thisSession,iTrial,:,:,:) = volume; 
        %voxelMat(iTrial,:) = reshape(volume, 1, numel(volume)); % reshape
        %into a single vector
    end
    
    % voxelMat is 2x106x104x104x72 (locs 1:7 have 15 betas each with 1 MEAN
    % at end = 15x7 + 1)
    
end

%% now need to get the 5D beta matrix into different conditions...

betaConditionTimingVector = [repmat([0,0,0,0,1,1,1,1,0,0,0,0,0,0,0],1,7) 0];
    
%contrastMat = [repmat([1 1 1 1 1 1 1 1 1 1 1 1 1 1 1],1,6),[-6 -6 -6 -6 -6 -6 -6 -6 -6 -6 -6 -6 -6 -6 -6]]; % ALL BETAS
contrastMat = [repmat([0 0 0 0 1 1 1 1 0 0 0 0 0 0 0],1,6),[0 0 0 0 -6 -6 -6 -6 0 0 0 0 0 0 0]];

% save single trial voxel mat with trial data mat
save([saveDir '/' sprintf('sj%02d_se%02d_single_trial.mat',sjNum,thisSession)],'voxelMat')

cd('/home/bullock/Scan_CPET/Analysis')
    

end