function rest_3Dto4D(sjNum,parent_dir)

%{
===========================================================================
Adapted Tylers Scripts by Jordan for Scan_CPET data 
===========================================================================
%}
%addpath(genpath('/home/bullock/Scan_CPET/Analysis'))
%addpath(genpath('/home/bullock/spm12'))

cd([parent_dir '/sj' int2str(sjNum) '/'])
% Initialize default SPM configurations for fMRI.

    setDefaultsSPM;
    
    matlabbatch = {};
    
% Get realigned/unwarped scans.

    matlabbatch{1}.spm.util.cat.vols  = cellstr(strcat([pwd '/data.functional.rest_pre/'], spm_select('List', [pwd '/data.functional.rest_pre'], '^uf.*nii$')));
    matlabbatch{1}.spm.util.cat.name  = 'ufrest_pre4D.nii';
    matlabbatch{1}.spm.util.cat.dtype = 4;
    
    matlabbatch{2}.spm.util.cat.vols  = cellstr(strcat([pwd '/data.functional.rest_post/'], spm_select('List', [pwd '/data.functional.rest_post'], '^uf.*nii$')));
    matlabbatch{2}.spm.util.cat.name  = 'ufrest_post4D.nii';
    matlabbatch{2}.spm.util.cat.dtype = 4;
    
% Get normalized/smoothed scans.

    matlabbatch{3}.spm.util.cat.vols  = cellstr(strcat([pwd '/data.functional.rest_pre/'], spm_select('List', [pwd '/data.functional.rest_pre'], '^swuf.*nii$'))); %edited from swuf
    matlabbatch{3}.spm.util.cat.name  = 'swufrest_pre4D.nii';
    matlabbatch{3}.spm.util.cat.dtype = 4;
    
    matlabbatch{4}.spm.util.cat.vols  = cellstr(strcat([pwd '/data.functional.rest_post/'], spm_select('List', [pwd '/data.functional.rest_post'], '^swuf.*nii$')));
    matlabbatch{4}.spm.util.cat.name  = 'swufrest_post4D.nii';
    matlabbatch{4}.spm.util.cat.dtype = 4;
    

% Run jobs.

    spm_jobman('run', matlabbatch);
    
% Compress outputs.

    unix(['gzip ' pwd '/data.functional.rest_pre/ufrest_pre4D.nii']);
    unix(['gzip ' pwd '/data.functional.rest_post/ufrest_post4D.nii']);
    
    unix(['gzip ' pwd '/data.functional.rest_pre/swufrest_pre4D.nii']);
    unix(['gzip ' pwd '/data.functional.rest_post/swufrest_post4D.nii']);
    
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