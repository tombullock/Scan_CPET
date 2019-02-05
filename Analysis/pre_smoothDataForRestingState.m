function pre_smoothDataForRestingState(taskDataPresent)

% Initialize default SPM configurations for fMRI.

    setDefaultsSPM;
    
    matlabbatch = {};
    
% Get all the normalized, realigned/unwarped functional data.

    mean   = cellstr(strcat([pwd 'data.functional.mean/'], spm_select('List', [pwd 'data.functional.mean'], '^meanu.*nii$')));
    
    rest_pre   = cellstr(strcat([pwd '/data.functional.rest_pre/'], spm_select('List', [pwd '/data.functional.rest_pre'], '^uf.*nii$')));
    rest_post   = cellstr(strcat([pwd '/data.functional.rest_post/'], spm_select('List', [pwd '/data.functional.rest_post'], '^uf.*nii$')));
    
    if taskDataPresent
        task_pre   = cellstr(strcat([pwd '/data.functional.task_pre/'], spm_select('List', [pwd '/data.functional.task_pre'], '^uf.*nii$')));
        task_post   = cellstr(strcat([pwd '/data.functional.task_post/'], spm_select('List', [pwd '/data.functional.task_post'], '^uf.*nii$')));
    end
    
        
% Specify smoothing parameters.

    if taskDataPresent
        matlabbatch{1}.spm.spatial.smooth.data   = [mean; rest_pre; rest_post; task_pre; task_post];
    else
        matlabbatch{1}.spm.spatial.smooth.data   = [mean; rest_pre; rest_post];
    end
        
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