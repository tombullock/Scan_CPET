%{
contrasts_visHRF
Author: Tom Bullock
Date: 12.22.18

Extract voxels from betas where the HRF is peaking (e.g. between ~3 and 6
secs) and apply various contrasts to all subjects

12 stimuli, 36 presentations per stim, 
Each stimulus is on for .5 secs
TR is .4 secs

FIR length is 12 secs
FIR order is 30 secs

Betas are in order:
[loc1,loc2,loc3,loc4,loc5,loc6,ori1,ori2,ori3,ori4,ori5,ori6]

SINGLE SESSION:

This gives us 361 betas (12 stim types, 30 betas per stim type (grouped)) +
1 extra beta at end.

DOUBLE SESSION:
This gives us 722 betas (above, repeated twice)


%}

clear contrastMat

% to capture the HRF peak (~3-6 secs),this is the per-stim mat
betaTimingMat = [0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]; 
betaTimingMatZeros = repmat(0,1,30);


% %% SINGLE SESSION - PERIPHERAL VS CENTRL
% % to compare all ori stim (central) vs. all location stim (peripheral)
% % apply the following mat:
% contrastMat = [...
%     repmat(betaTimingMat*-1,1,6),...
%     repmat(betaTimingMat*1,1,6),...
%     0
%     ];

%% Combined pre and post exercise sessions - peripheral locations vs. central locations
contrastName_1 = 'Peripheral vs Central';
contrastMat_Peripheral_vs_Central = [...
    repmat(betaTimingMat*-1,1,6),...
    repmat(betaTimingMat*1,1,6),...
    0,...
    repmat(betaTimingMat*-1,1,6),...
    repmat(betaTimingMat*1,1,6),...
    0,...
    ];

%% Pre-exercise vs. Post-exercise - central locations only 
contrastName_2 = 'Pre- vs Post- Exercise Central Locs Only';
contrastMat_Pre_vs_Post_Central_Only = [...
    repmat(betaTimingMatZeros,1,6),...
    repmat(betaTimingMat*-1,1,6),...
    0,...
    repmat(betaTimingMatZeros,1,6),...
    repmat(betaTimingMat*1,1,6),...
    0,...
    ];

%% Pre-exercise vs. Post-exercise - all locations (central and peripheral)
contrastName_3 = 'Pre- vs_Post- Exercise All Locations';
contrastMat_Pre_vs_Post_Central_All_Locations = [...
    repmat(betaTimingMat*-1,1,6),...
    repmat(betaTimingMat*-1,1,6),...
    0,...
    repmat(betaTimingMat*1,1,6),...
    repmat(betaTimingMat*1,1,6),...
    0,...
    ];



%% Apply contrasts to respective folders
rDir = '/home/bullock/Scan_CPET/Subject_Data';
subjects = [101,103,109,111,112,113,119,121,125,127,130,133,135];

subjects =107; % why won't this person run?


for iSub=1:length(subjects)
    sjNum=subjects(iSub)
    
    destDir = [rDir '/sj' num2str(sjNum) '/data.groupedTrial.task_prePost'];
    
    matlabbatch = [];
    
    matlabbatch{1}.spm.stats.con.spmmat = cellstr(strcat(destDir,'/SPM.mat'));
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = contrastName_1;
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.convec = contrastMat_Peripheral_vs_Central;
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = contrastName_2;
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.convec = contrastMat_Pre_vs_Post_Central_Only;
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    
    matlabbatch{1}.spm.stats.con.consess{3}.tcon.name = contrastName_3;
    matlabbatch{1}.spm.stats.con.consess{3}.tcon.convec = contrastMat_Pre_vs_Post_Central_All_Locations;
    matlabbatch{1}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
    
    matlabbatch{1}.spm.stats.con.delete = 1;
    spm_jobman('run',matlabbatch);
    
end
