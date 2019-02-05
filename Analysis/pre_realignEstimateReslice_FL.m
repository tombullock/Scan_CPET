%{
pre_realignEstimateReslice_FL
Author: Tom Bullock (adapted from Tyler Santander scripts)
Date: 07.23/.18

Note: not using fieldmaps...need to figure out which ones to use (look at
protocol)
%}

function pre_realignEstimateReslice_FL

% Initialize default SPM configurations for fMRI.
setDefaultsSPM;

%% get scans from the different data files
matlabbatch = {};

% vdm = cellstr(strcat([pwd '/data.fieldmap2/'], ...
%     spm_select('List', [pwd '/data.fieldmap2'], '^vdm.*nii$')));

matlabbatch{1}.spm.spatial.realignunwarp.data(1).scans  = cellstr(strcat([pwd '/data.functional.FL_b1/'], ...
    spm_select('List', [pwd '/data.functional.FL_b1'], '^f.*nii$')));

matlabbatch{1}.spm.spatial.realignunwarp.data(1).pmscan = {' '}; % empty because no field maps

matlabbatch{1}.spm.spatial.realignunwarp.data(2).scans  = cellstr(strcat([pwd '/data.functional.FL_b2/'], ...
    spm_select('List', [pwd '/data.functional.FL_b2'], '^f.*nii$')));

matlabbatch{1}.spm.spatial.realignunwarp.data(2).pmscan = {' '}; % empty because no field maps



% Define all parameters for realign/unwarp estimation.

% Motion estimation for realignment.
matlabbatch{1}.spm.spatial.realignunwarp.eoptions.quality = 1;
matlabbatch{1}.spm.spatial.realignunwarp.eoptions.sep     = 4;
matlabbatch{1}.spm.spatial.realignunwarp.eoptions.fwhm    = 5;
matlabbatch{1}.spm.spatial.realignunwarp.eoptions.rtm     = 0;
matlabbatch{1}.spm.spatial.realignunwarp.eoptions.einterp = 7;
matlabbatch{1}.spm.spatial.realignunwarp.eoptions.ewrap   = [0 0 0];
matlabbatch{1}.spm.spatial.realignunwarp.eoptions.weight  = '';

% Deformation field estimation for unwarp.
matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.basfcn   = [12 12];
matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.regorder = 1;
matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.lambda   = 100000;
matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.jm       = 0;
matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.fot      = [4 5];
matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.sot      = [];
matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.uwfwhm   = 4;
matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.rem      = 1;
matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.noi      = 5;
matlabbatch{1}.spm.spatial.realignunwarp.uweoptions.expround = 'Average';

% Interpolation/reslicing.
matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];
matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.rinterp = 7;
matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.wrap    = [0 0 0];
matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.mask    = 1;
matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.prefix  = 'u';



% Run motion/distortion correction.
spm_jobman('run', matlabbatch);

% Create new folder for the mean functional image and move it there. NOTE
% that I'm using the mean from the first scan (i.e. rest, pre-VO2max) as
% this should be good for the rest of the scans.  Might want to reconsider
% this though because subject is entering/exiting the scanner to do VO2...
mkdir('./data.functional.mean_FL');
unix('mv ./data.functional.FL_b1/meanuf* ./data.functional.mean_FL');

% Estimate framewise displacement for each scanning run. Here, we convert
% rotational displacements to translations by turning degrees into arc
% lengths around a 50mm sphere (average distance from cerebral cortex to
% center of head); take the first derivative (TR-to-TR movement); and sum
% across columns (total movement between each frame).

% % % % Initialize structure for resting-state.
% % % framewiseDisplacement.rest = [];
% % % 
% % % % Obtain realignment parameters.
% % % rpData = load(strcat([pwd '/data.functional.rest/'], ...
% % %     spm_select('List', [pwd '/data.functional.rest'], '^rp.*txt$')));
% % % 
% % % % Compute and store.
% % % rpData(:,4:6) = rpData(:,4:6) .* (2*50*pi/360);
% % % dx            = diff(rpData);
% % % fwd           = sum(abs(dx),2);
% % % 
% % % framewiseDisplacement.rest.series = fwd;
% % % framewiseDisplacement.rest.mean   = mean(fwd);
% % % framewiseDisplacement.rest.max    = max(fwd);

% Loop through the scanning runs

for iRun = 1:2
    
    if iRun==1; thisRun = 'FL_b1';
    elseif iRun==2; thisRun = 'FL_b2';
    end
    
    % Initialize structure for this run.
    framewiseDisplacement.(['run' num2str(iRun)]) = [];
    
    % Obtain realignment parameters.
    rpData = load(strcat([pwd '/data.functional.' thisRun '/'], ...
        spm_select('List', [pwd '/data.functional.' thisRun], '^rp.*txt$')));
    
    % Compute and store.
    rpData(:,4:6) = rpData(:,4:6) .* (2*50*pi/360);
    dx            = diff(rpData);
    fwd           = sum(abs(dx),2);
    
    framewiseDisplacement.(['run' num2str(iRun)]).series = fwd;
    framewiseDisplacement.(['run' num2str(iRun)]).mean   = mean(fwd);
    framewiseDisplacement.(['run' num2str(iRun)]).max    = max(fwd);
    framewiseDisplacement.(['run' num2str(iRun)]).thisRun= thisRun;
end

% Save structure.
mkdir('./data.fwd_FL');
cd('./data.fwd_FL');
save framewiseDisplacement framewiseDisplacement;
cd ..


end




%-------------------------------------------------------------------------%
% BEGIN SUBROUTINES                                                       %
%-------------------------------------------------------------------------%

% Initialize default parameters for SPM.
%-------------------------------------------------------------------------%
function setDefaultsSPM

    spm('defaults','fMRI');
    warning off MATLAB:FINITE:obsoleteFunction;
    spm_jobman('initcfg');
    
end
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
% END SUBROUTINES                                                         %
%-------------------------------------------------------------------------%
