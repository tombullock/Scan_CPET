%{
coregisterEstimateReslice
Author: Tom Bullock (based on Tyler Santander scripts)
Date: 07.23.18
%}

function pre_coregisterEstimateReslice

%%%ss-ms112T1.nii % source

%meanuf2018-05-30_13-44-135755-00001-00001-1.nii

% Initialize default SPM configurations for fMRI.

setDefaultsSPM;

matlabbatch = {};

% Specify REFERENCE SCAN (i.e. the thing that stays still) - here, we want
% this to be the bias-regularised, skull-stripped hires image. Note I've
% assumed the file begins with 'ss-ms' (skull-stripped, bias-corrected
% structural), per the segmentStrip function we ran before.
matlabbatch{1}.spm.spatial.coreg.estimate.ref = cellstr(strcat([pwd '/data.anatomical.hires/'], spm_select('List', [pwd '/data.anatomical.hires'], '^ss-ms.*nii$')));

% Specify SOURCE SCAN (i.e. the thing we're mapping onto the reference
% image) - this is the mean functional scan after we realign/unwarp. We
% assume the file begins with 'meanuf' (mean unwarped image). Note that we
% also need to specify the other functional data so the estimated
% coregistration parameters can be added to those image headers. We won't
% actually do any reslicing, though - it's enough to simply add this
% information to the headers for now.
matlabbatch{1}.spm.spatial.coreg.estimate.source = cellstr(strcat([pwd '/data.functional.mean/'], spm_select('List', [pwd '/data.functional.mean'], '^meanuf.*nii$')));

rest_pre   = cellstr(strcat([pwd '/data.functional.rest_pre/'], spm_select('List', [pwd '/data.functional.rest_pre'], '^uf.*nii$')));
rest_post   = cellstr(strcat([pwd '/data.functional.rest_post/'], spm_select('List', [pwd '/data.functional.rest_post'], '^uf.*nii$')));
task_pre   = cellstr(strcat([pwd '/data.functional.task_pre/'], spm_select('List', [pwd '/data.functional.task_pre'], '^uf.*nii$')));
task_post   = cellstr(strcat([pwd '/data.functional.task_post/'], spm_select('List', [pwd '/data.functional.task_post'], '^uf.*nii$')));


matlabbatch{1}.spm.spatial.coreg.estimate.other             = [rest_pre; rest_post; task_pre; task_post];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep      = [4 2];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol      = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm     = [7 7];

% Run coregistration.

spm_jobman('run',matlabbatch);


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