%{
segmentStrip_VO2
Author: Tom Bullock (adapted from Tyler Santander scripts)
Date: 07.23.18

NOTE: make more flexible wrt subject nums
%}

function segmentStrip_VO2

% % % CD TO DIR
% % cd /Users/tombullock/Documents/Psychology/GABOR_VO2_ANALYSIS/Subject_Data/sj112

% Initialize default SPM configurations for fMRI.

    setDefaultsSPM;
    
    matlabbatch = {};
    
% Tell SPM where the hires scan lives, grab it.

    %%%%cd /Users/tombullock/Documents/Psychology/GABOR_VO2_ANALYSIS/Subject_Data/sj112
    hiresPath = [pwd '/data.anatomical.hires'];
    %%%%cd /Users/tombullock/Documents/Psychology/GABOR_VO2_ANALYSIS/Analysis
    
    matlabbatch{1}.spm.spatial.preproc.channel.vols = cellstr(strcat([hiresPath '/'], spm_select('List', hiresPath, '^s.*nii$')));
        
% Set parameters for bias field correction (i.e. intensity normalization).

   matlabbatch{1}.spm.spatial.preproc.channel.biasreg  = 0.001;
   matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = 60;
   matlabbatch{1}.spm.spatial.preproc.channel.write    = [0 1];
        
% Define tissue probability maps.

    matlabbatch{1}.spm.spatial.preproc.tissue(1).tpm    = cellstr(fullfile(spm('Dir'), 'tpm', 'TPM.nii,1'));
    matlabbatch{1}.spm.spatial.preproc.tissue(1).ngaus  = 1;
    matlabbatch{1}.spm.spatial.preproc.tissue(1).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(1).warped = [1 1];
    
    matlabbatch{1}.spm.spatial.preproc.tissue(2).tpm    = cellstr(fullfile(spm('Dir'), 'tpm', 'TPM.nii,2'));
    matlabbatch{1}.spm.spatial.preproc.tissue(2).ngaus  = 1;
    matlabbatch{1}.spm.spatial.preproc.tissue(2).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(2).warped = [1 1];
    
    matlabbatch{1}.spm.spatial.preproc.tissue(3).tpm    = cellstr(fullfile(spm('Dir'), 'tpm', 'TPM.nii,3'));
    matlabbatch{1}.spm.spatial.preproc.tissue(3).ngaus  = 2;
    matlabbatch{1}.spm.spatial.preproc.tissue(3).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(3).warped = [1 1];
    
    matlabbatch{1}.spm.spatial.preproc.tissue(4).tpm    = cellstr(fullfile(spm('Dir'), 'tpm', 'TPM.nii,4'));
    matlabbatch{1}.spm.spatial.preproc.tissue(4).ngaus  = 3;
    matlabbatch{1}.spm.spatial.preproc.tissue(4).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(4).warped = [0 0];
    
    matlabbatch{1}.spm.spatial.preproc.tissue(5).tpm    = cellstr(fullfile(spm('Dir'), 'tpm', 'TPM.nii,5'));
    matlabbatch{1}.spm.spatial.preproc.tissue(5).ngaus  = 4;
    matlabbatch{1}.spm.spatial.preproc.tissue(5).native = [1 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(5).warped = [0 0];
    
    matlabbatch{1}.spm.spatial.preproc.tissue(6).tpm    = cellstr(fullfile(spm('Dir'), 'tpm', 'TPM.nii,6'));
    matlabbatch{1}.spm.spatial.preproc.tissue(6).ngaus  = 2;
    matlabbatch{1}.spm.spatial.preproc.tissue(6).native = [0 0];
    matlabbatch{1}.spm.spatial.preproc.tissue(6).warped = [0 0];
        
% Set parameters for the estimation of deformation maps - here we'll get
% both forward deformations (mapping subject space to MNI) and inverse
% deformations (MNI to subject). The voxels in these images contain 3D
% tensors that define the spatial warp from one image to another.
        
    matlabbatch{1}.spm.spatial.preproc.warp.mrf     = 1;
    matlabbatch{1}.spm.spatial.preproc.warp.cleanup = 1;
    matlabbatch{1}.spm.spatial.preproc.warp.reg     = [0 0.001 0.5 0.05 0.2];
    matlabbatch{1}.spm.spatial.preproc.warp.affreg  = 'mni';
    matlabbatch{1}.spm.spatial.preproc.warp.fwhm    = 0;
    matlabbatch{1}.spm.spatial.preproc.warp.samp    = 3;
    matlabbatch{1}.spm.spatial.preproc.warp.write   = [1 1];
        
% Run segmentation.
    
    spm_jobman('run', matlabbatch);
        
% Grab grey, white, and CSF segments.
    
    gm  = cellstr(strcat([hiresPath '/'], spm_select('List', hiresPath, '^c1s.*nii$')));
    wm  = cellstr(strcat([hiresPath '/'], spm_select('List', hiresPath, '^c2s.*nii$')));
    csf = cellstr(strcat([hiresPath '/'], spm_select('List', hiresPath, '^c3s.*nii$')));
        
% Get corrected hires - here, the 'm' prefix indicates a MODULATED (i.e. 
% bias regularised) image, per SPM's convention.
    
    biasCorr = cellstr(strcat([hiresPath '/'], spm_select('List', hiresPath, '^ms.*nii$')));
        
% Skull-strip the T1 using ImCalc.
    
    [~,name,~] = fileparts(char(biasCorr));
        
    setDefaultsSPM;
    
    matlabbatch = {};

    matlabbatch{1}.spm.util.imcalc.input          = cellstr([gm; wm; csf; biasCorr]);

    matlabbatch{1}.spm.util.imcalc.output         = [hiresPath '/ss-' name '.nii'];
    matlabbatch{1}.spm.util.imcalc.expression     = '(i1 + i2 + i3) .* i4';

    matlabbatch{1}.spm.util.imcalc.options.dmtx   = 0;
    matlabbatch{1}.spm.util.imcalc.options.mask   = 0;
    matlabbatch{1}.spm.util.imcalc.options.interp = 1;
    matlabbatch{1}.spm.util.imcalc.options.dtype  = 4;

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