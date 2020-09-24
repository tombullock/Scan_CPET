function csfMRIv2_smooth_Jordan(sjNum,parent_dir)

cd([parent_dir '/sj' int2str(sjNum) '/'])
% Initialize default SPM configurations for fMRI.

    setDefaultsSPM;
    
    matlabbatch = {};
    
% Get all the normalized, realigned/unwarped functional data.

    allEPI_restPre = cellstr(strcat([pwd '/data.functional.rest_pre/'], spm_select('List', [pwd '/data.functional.rest_pre'], '^wuf.*nii$')));
    
    allEPI_restPost = cellstr(strcat([pwd '/data.functional.rest_post/'], spm_select('List', [pwd '/data.functional.rest_post'], '^wuf.*nii$')));
    
    meanScan = cellstr(strcat([pwd '/data.functional.mean/'], spm_select('List', [pwd '/data.functional.mean'], '^wmeanu.*nii$')));
    allEPI_restPre   = [allEPI_restPre; meanScan];
    allEPI_restPost   = [allEPI_restPost; meanScan];
        
% Specify smoothing parameters.

    matlabbatch{1}.spm.spatial.smooth.data   = [allEPI_restPre; allEPI_restPost];
    matlabbatch{1}.spm.spatial.smooth.fwhm   = [5 5 5];
    matlabbatch{1}.spm.spatial.smooth.dtype  = 0;
    matlabbatch{1}.spm.spatial.smooth.im     = 0;
    matlabbatch{1}.spm.spatial.smooth.prefix = 's';
    
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