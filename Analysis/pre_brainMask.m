%{
brainMask_VO2
Author: Tom Bullock (adapted from Tyler Santander scripts)
Date: 07.23.18

NOTES: 

%}

function pre_brainMask(smoothMask)

% Initialize default SPM configurations for fMRI.

    setDefaultsSPM;
    
    matlabbatch = {};
    
% Tell SPM where the hires data live, get the gray and white matter
% segments (in native subject space since we aren't normalizing to a
% standard template).

    %%%cd /Users/tombullock/Documents/Psychology/GABOR_VO2_ANALYSIS/Subject_Data/sj112

    hiresPath = [pwd '/data.anatomical.hires'];
    
    graySeg   = [hiresPath '/' spm_select('List', hiresPath, '^c1s.*nii$')];
    whiteSeg  = [hiresPath '/' spm_select('List', hiresPath, '^c2s.*nii$')];
    
% Create a new directory in which to store the brainmask.

    mkdir([pwd '/data.anatomical.mask']);
    cd([pwd '/data.anatomical.mask']);
    unix('rm brainmask.nii');
    
% Specify inputs to ImCalc and compute mask.

    matlabbatch{1}.spm.util.imcalc.input      = cellstr([graySeg; whiteSeg]);
    matlabbatch{1}.spm.util.imcalc.output     = 'brainmask.nii';
    matlabbatch{1}.spm.util.imcalc.expression = '(i1 > 0.05) | (i2 > 0.05)';

    matlabbatch{1}.spm.util.imcalc.options.dmtx   = 0;
    matlabbatch{1}.spm.util.imcalc.options.mask   = 0;
    matlabbatch{1}.spm.util.imcalc.options.interp = 1;
    matlabbatch{1}.spm.util.imcalc.options.dtype  = 4;
    
    spm_jobman('run',matlabbatch);
    
% Smooth if necessary (probably not too important since we aren't doing any
% normalization / averaging across subjects).

    if smoothMask
        
        setDefaultsSPM;
        
        matlabbatch = {};
        
        matlabbatch{1}.spm.spatial.smooth.data   = cellstr([pwd '/brainmask.nii']);
        matlabbatch{1}.spm.spatial.smooth.fwhm   = [5 5 5];
        matlabbatch{1}.spm.spatial.smooth.dtype  = 0;
        matlabbatch{1}.spm.spatial.smooth.im     = 0;
        matlabbatch{1}.spm.spatial.smooth.prefix = 's';
    
        spm_jobman('run',matlabbatch);
        
    end
    
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