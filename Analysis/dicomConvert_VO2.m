%{
dicomConvert_VO2
Author: Tom Bullock (based on Tyler scripts)
Date: 07.23.18

NOTES: 
Why does this not run with my script?  Runs ok via gui with same
commands...
%}

function dicomConvert_VO2

% Rename the dicom directory pulled off BIC storage.

    dicomDir = dir([pwd '/study*']);
    unix(['mv ./' dicomDir.name ' ./archive.rawdata']);

% Initialize default SPM configurations for fMRI.

    setDefaultsSPM;
    
    matlabbatch = {};
    
% Grab all the dicom images.

    matlabbatch{1}.spm.util.import.dicom.data = cellstr(strcat([pwd '/archive.rawdata/'], ...
        spm_select('List', [pwd '/archive.rawdata'], '^MR*')));
    
% Outpute .nii files in folders based on protocol name, run conversion.
    
    matlabbatch{1}.spm.util.import.dicom.root             = 'series';
    matlabbatch{1}.spm.util.import.dicom.outdir           = cellstr(pwd);
    matlabbatch{1}.spm.util.import.dicom.protfilter       = '.*';
    matlabbatch{1}.spm.util.import.dicom.convopts.format  = 'nii';
    matlabbatch{1}.spm.util.import.dicom.convopts.meta    = 0;
    matlabbatch{1}.spm.util.import.dicom.convopts.icedims = 0;
    
    spm_jobman('run',matlabbatch);
    
% % Compress the raw data archive and delete the original directory. (leave
% this for now)
% 
%     unix('zip -q -r archive.rawdata.zip archive.rawdata');
%     unix('rm -r archive.rawdata');
    
% Toss the localizers, rename the other protocols into something more
% intelligible for later preprocessing.

    unix('rm -r localizer*');
    unix('mv ./t1 ./data.anatomical.hires'); % first grab t1 data from Allison folder
    unix('mv ./epi_mb_3x3x3_400TR_Resting_Physio_pre_0002 ./data.functional.rest_pre');
    unix('mv ./epi_mb_3x3x3_400TR_Resting_Physio_post_0005 ./data.functional.rest_post');
    unix('mv ./epi_mb_3x3x3_400TR_Gra_Physio_pre_0003 ./data.functional.task_pre');
    unix('mv ./epi_mb_3x3x3_400TR_Gra_Physio_post_0006 ./data.functional.task_post');
    
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



% %%
% matlabbatch{1}.spm.util.import.dicom.root = 'series';
% matlabbatch{1}.spm.util.import.dicom.outdir = {'/Users/tombullock/Documents/Psychology/GABOR_VO2_ANALYSIS/Subject_Data/sj112'};
% matlabbatch{1}.spm.util.import.dicom.protfilter = '.*';
% matlabbatch{1}.spm.util.import.dicom.convopts.format = 'nii';
% matlabbatch{1}.spm.util.import.dicom.convopts.meta = 0;
% matlabbatch{1}.spm.util.import.dicom.convopts.icedims = 0;