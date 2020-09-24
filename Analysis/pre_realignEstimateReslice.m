%{
pre_realignEstimateReslice
Author: Tom Bullock (adapted from Tyler Santander scripts)
Date: 07.23/.18

NOTE: why didn't this bring up the movement summary pdf?  Did it get saved?

ADD IN THE MOTION STATS CALCULATION STUFF FROM TYLER

%% ADD IN THE UNWARP STUFF.  

%}

function pre_realignEstimateReslice(taskDataPresent)

% task data present for this subject?
%%%%taskDataPresent = 0;

% Initialize default SPM configurations for fMRI.
setDefaultsSPM;

%% get scans from the different data files
matlabbatch = {};



matlabbatch{1}.spm.spatial.realignunwarp.data(1).scans  = cellstr(strcat([pwd '/data.functional.rest_pre/'], ...
    spm_select('List', [pwd '/data.functional.rest_pre'], '^f.*nii$')));

matlabbatch{1}.spm.spatial.realignunwarp.data(1).pmscan = {' '}; % empty because no field maps

matlabbatch{1}.spm.spatial.realignunwarp.data(2).scans  = cellstr(strcat([pwd '/data.functional.rest_post/'], ...
    spm_select('List', [pwd '/data.functional.rest_post'], '^f.*nii$')));

matlabbatch{1}.spm.spatial.realignunwarp.data(2).pmscan = {' '}; % empty because no field maps

if taskDataPresent
    
    disp('PROCESSING TASK DATA')
    
    matlabbatch{1}.spm.spatial.realignunwarp.data(3).scans  = cellstr(strcat([pwd '/data.functional.task_pre/'], ...
        spm_select('List', [pwd '/data.functional.task_pre'], '^f.*nii$')));
    
    matlabbatch{1}.spm.spatial.realignunwarp.data(3).pmscan = {' '}; % empty because no field maps
    
    matlabbatch{1}.spm.spatial.realignunwarp.data(4).scans  = cellstr(strcat([pwd '/data.functional.task_post/'], ...
        spm_select('List', [pwd '/data.functional.task_post'], '^f.*nii$')));
    
    matlabbatch{1}.spm.spatial.realignunwarp.data(4).pmscan = {' '}; % empty because no field maps
    
else
    
    disp('NOT PROCESSING TASK DATA')
    
end


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
mkdir('./data.functional.mean');
unix('mv ./data.functional.rest_pre/meanuf* ./data.functional.mean');

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

if taskDataPresent==1
    theseRuns=1:4;
elseif taskDataPresent==0
    theseRuns=[1,3];
end

for iRun = theseRuns
    
    if iRun==1; thisRun = 'rest_pre';
    elseif iRun==2; thisRun = 'task_pre';
    elseif iRun==3; thisRun = 'rest_post';
    elseif iRun==4; thisRun = 'task_post';
    end
    
    % Initialize structure for this run.
    framewiseDisplacement.(['run' num2str(iRun)]) = [];
    
    % Obtain realignment parameters.
    rpData = load(strcat([pwd '/data.functional.' thisRun '/'], ...
        spm_select('List', [pwd '/data.functional.' thisRun], '^rp.*txt$')));
    
    % Compute and store.
    %rpData(:,4:6) = rpData(:,4:6) .* (2*50*pi/360);
    rpData(:,4:6) = rpData(:,4:6)*50;
    dx            = diff(rpData);
    fwd           = sum(abs(dx),2);
    
    framewiseDisplacement.(['run' num2str(iRun)]).series = fwd;
    framewiseDisplacement.(['run' num2str(iRun)]).mean   = mean(fwd);
    framewiseDisplacement.(['run' num2str(iRun)]).max    = max(fwd);
    framewiseDisplacement.(['run' num2str(iRun)]).thisRun= thisRun;
end

% Save structure.
mkdir('./data.fwd');
cd('./data.fwd');
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
