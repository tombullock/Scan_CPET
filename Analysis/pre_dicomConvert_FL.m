%{
pre_dicomConvert_FL
Author: Tom Bullock (based on Tyler Santander scripts)
Date: 07.23.18
%}

function pre_dicomConvert_FL

% Rename the dicom directory pulled off BIC storage.

    dicomDir = dir([pwd '/study*']);
    unix(['mv ./' dicomDir.name ' ./archive.rawdata_FL']);

% Initialize default SPM configurations for fMRI.

    setDefaultsSPM;
    
    matlabbatch = {};
    
% Grab all the dicom images.

    matlabbatch{1}.spm.util.import.dicom.data = cellstr(strcat([pwd '/archive.rawdata_FL/'], ...
        spm_select('List', [pwd '/archive.rawdata_FL'], '^MR*')));
    
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
    unix('mv ./cmrr_dsi* ./data.anatomical.dsi');
    
    unix('mv ./gre_field_mapping_2mm_0002 ./data.fieldmap.FL_map1');
    unix('mv ./gre_field_mapping_2mm_0003 ./data.fieldmap.FL_map2');
    
    unix('mv ./epi_mb_700TR_R016a_0004 ./data.functional.ret_map_b1');
    unix('mv ./epi_mb_700TR_R016a_0005 ./data.functional.ret_map_b2');
    unix('mv ./epi_mb_700TR_R016a_0006 ./data.functional.ret_map_b3');
    unix('mv ./epi_mb_700TR_R016a_0007 ./data.functional.FL_b1');
    unix('mv ./epi_mb_700TR_R016a_0008 ./data.functional.FL_b2');
    
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