%{
Compile_Betas_For_Modeling
Author: Tom Bullock
Date: 07.21.18
%}

function compile_Betas_For_Modeling

sjNum = 127;
thisSession = 1; % 1=pre VO2, 2=post VO2

saveDir = '/Users/tombullock/Documents/Psychology/GABOR_VO2_ANALYSIS/Single_Trial_Data';

cd /Users/tombullock/Documents/Psychology/GABOR_VO2_ANALYSIS/sj127_RAW/glmResults

% get all trial betas
d=dir('trial*.nii');
for iTrial=1:length(d)
    disp(['Processing Trial ' num2str(iTrial)])
    V = spm_vol(sprintf('./trial%d_beta.nii',iTrial));
    volume = spm_read_vols(V);
    voxelMat(iTrial,:) = reshape(volume, 1, numel(volume));
end

% load trialmat (for trial details)
load('/Users/tombullock/Documents/Psychology/GABOR_VO2_ANALYSIS/TrialMats/sj127_se01_VO2scan_for_MR.mat')

% save single trial voxel mat with trial data mat
save([saveDir '/' sprintf('sj%02d_se%02d_single_trial.mat',sjNum,thisSession)],'allTrialsMat','voxelMat','colNames')

end


% % code for getting voxel data out of the beta.nii
% V = spm_vol('./trial1_beta.nii');
% [volume] = spm_read_vols(V);
% data2D = reshape(volume, 1, numel(volume));