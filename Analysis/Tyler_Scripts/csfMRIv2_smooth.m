function csfMRIv2_smooth(nRun)

% Initialize default SPM configurations for fMRI.

    setDefaultsSPM;
    
    matlabbatch = {};
    
% Get all the normalized, realigned/unwarped functional data.

    allEPI = cellstr(strcat([pwd '/data.functional.rest/'], spm_select('List', [pwd '/data.functional.rest'], '^wurun.*nii$')));
    
    for iRun = 1:nRun
        
        scans  = cellstr(strcat([pwd '/data.functional.run' num2str(iRun) '/'], spm_select('List', [pwd '/data.functional.run' num2str(iRun)], '^wurun.*nii$')));
        
        allEPI = [allEPI; scans];
        
    end
    
    meanScan = cellstr(strcat([pwd 'data.functional.mean/'], spm_select('List', [pwd 'data.functional.mean'], '^wmeanu.*nii$')));
    allEPI   = [allEPI; meanScan];
        
% Specify smoothing parameters.

    matlabbatch{1}.spm.spatial.smooth.data   = allEPI;
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