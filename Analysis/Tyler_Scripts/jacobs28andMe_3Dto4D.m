function jacobs28andMe_3Dto4D(repetitionTime)

% Initialize default SPM configurations for fMRI.

    setDefaultsSPM;
    
    matlabbatch = {};
    
% Get realigned/unwarped scans.

    matlabbatch{1}.spm.util.cat.vols  = cellstr(strcat([pwd '/data.functional.rest/'], spm_select('List', [pwd '/data.functional.rest'], '^uf.*nii$')));
    matlabbatch{1}.spm.util.cat.name  = 'ufrest4D.nii';
    matlabbatch{1}.spm.util.cat.dtype = 4;
    matlabbatch{1}.spm.util.cat.RT    = repetitionTime;
    
% Get normalized/smoothed scans.

    matlabbatch{2}.spm.util.cat.vols  = cellstr(strcat([pwd '/data.functional.rest/'], spm_select('List', [pwd '/data.functional.rest'], '^swuf.*nii$')));
    matlabbatch{2}.spm.util.cat.name  = 'swufrest4D.nii';
    matlabbatch{2}.spm.util.cat.dtype = 4;
    matlabbatch{2}.spm.util.cat.RT    = repetitionTime;
    
% Run jobs.

    spm_jobman('run', matlabbatch);
    
% Compress outputs.

    unix(['gzip ' pwd '/data.functional.rest/ufrest4D.nii']);
    unix(['gzip ' pwd '/data.functional.rest/swufrest4D.nii']);
    
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