%{
compile_betas_IEM
Author: Tom Bullock
Date: 07.21.18
%}

function compile_betas_IEM(sjNum,thisSession)

addpath('/home/bullock/spm12')

if thisSession==1
    sessionID = 'task_pre';
elseif thisSession==2
    sessionID = 'task_post';
end

saveDir = '/home/bullock/Scan_CPET/Single_Trial_Data';

cd(['/home/bullock/Scan_CPET/Subject_Data' '/sj' num2str(sjNum) '/' 'data.singleTrial.' sessionID])

%%cd /Users/tombullock/Documents/Psychology/GABOR_VO2_ANALYSIS/sj127_RAW/glmResults

% get all trial betas
d=dir('trial*.nii');
for iTrial=1:length(d)
    disp(['Processing Trial ' num2str(iTrial)])
    V = spm_vol(sprintf('./trial%d_beta.nii',iTrial));
    volume = spm_read_vols(V);
    voxelMat(iTrial,:) = reshape(volume, 1, numel(volume));
end

% load trialmat (for trial details)
load(['/home/bullock/Scan_CPET/Trial_Data' '/' sprintf('sj%d_se%02d_VO2scan_for_MR.mat',sjNum,thisSession)])

%%load('/Users/tombullock/Documents/Psychology/GABOR_VO2_ANALYSIS/TrialMats/sj127_se01_VO2scan_for_MR.mat')

% save single trial voxel mat with trial data mat
save([saveDir '/' sprintf('sj%02d_se%02d_single_trial.mat',sjNum,thisSession)],'allTrialsMat','voxelMat','colNames')

cd('/home/bullock/Scan_CPET/Analysis')

end


% % code for getting voxel data out of the beta.nii
% V = spm_vol('./trial1_beta.nii');
% [volume] = spm_read_vols(V);
% data2D = reshape(volume, 1, numel(volume));