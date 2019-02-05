function pre_coregister_anatomical2functional

% Initialize default SPM configurations for fMRI.

    setDefaultsSPM;
    
    matlabbatch = {};
    
% We're basically just going to reverse what we did before, so that now the
% mean realigned/unwarped EPI is the reference scan (the thing staying
% still) and we'll jiggle the hires to match it. Then we'll apply that warp
% to the brainmask so it's all in EPI space. I think this is preferable
% because the EPIs are already in the same space, so we only need to worry
% about warping/interpolating the hires and mask (rather than a whole bunch
% of timeseries). Also, just as a fun fact (probably more than you really
% need to know haha), there are good physical reasons why we'd want to warp
% anatomical to functional and not the other way around - even though 
% that's typically how we have to preprocess fMRI data. Namely, because 
% EPIs are collected in the (x,y) plane, so we ideally want to restrict
% any deformation / distortion correction to BOLD space whenever possible
% (this is why the 'unwarp' routine is mostly concerned with out-of-plane
% rotations, i.e. pitch and roll).

%     hiresDir = 'path/to/anatomical';
%     meanDir  = 'path/to/meanuf';
%     maskDir  = 'path/to/brainmask';
    
    hiresDir = [pwd '/data.anatomical.hires'];
    meanDir = [pwd '/data.functional.mean'];
    maskDir = [pwd '/data.anatomical.mask'];
    
    matlabbatch{1}.spm.spatial.coreg.estwrite.ref    = cellstr(strcat([meanDir '/'], spm_select('List', meanDir, '^meanuf.*nii$')));
    matlabbatch{1}.spm.spatial.coreg.estwrite.source = cellstr(strcat([hiresDir '/'], spm_select('List', hiresDir, '^ss-ms.*nii$')));
    matlabbatch{1}.spm.spatial.coreg.estwrite.other  = cellstr(strcat([maskDir '/'], spm_select('List', maskDir, '^brainmask.*nii$')));
    
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep      = [4 2];
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol      = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm     = [7 7];
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp   = 4;
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap     = [0 0 0];
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask     = 0;
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix   = 'r';
    
% Estimate coregistration and reslice.

    spm_jobman('run', matlabbatch);
    
% I'd maybe test this out on a single subject, then use CheckReg to make
% sure the mean, hires, and mask (the latter two will have generated files
% with an 'r' prefix) are aligned. You'll notice that this will result in
% downsampled (i.e. 3mm EPI space) hires and mask images, which is 
% unavoidable due to reslicing after estimating the coregistration
% parameters, but it shouldn't be problematic.
    
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