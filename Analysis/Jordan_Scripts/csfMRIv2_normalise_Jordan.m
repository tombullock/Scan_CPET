function csfMRIv2_normalise_Jordan(sjNum,parent_dir)


cd([parent_dir '/sj' int2str(sjNum) '/'])
% Initialize default SPM configurations for fMRI.

    setDefaultsSPM;
    
    matlabbatch = {};
    
% Normalise the (skull-stripped, bias-corrected) hires first.
%{
Tom already does this
    matlabbatch{1}.spm.spatial.normalise.write.subj.def        = cellstr(strcat([pwd '/data.anatomical.' hiresSeq '/'], spm_select('List', [pwd '/data.anatomical.' hiresSeq], '^y.*nii$')));
    matlabbatch{1}.spm.spatial.normalise.write.subj.resample   = cellstr(strcat([pwd '/data.anatomical.' hiresSeq '/'], spm_select('List', [pwd '/data.anatomical.' hiresSeq], '^ss-mt1.*nii$')));
    matlabbatch{1}.spm.spatial.normalise.write.woptions.bb     = [-78 -112 -70; 78 76 85];
    matlabbatch{1}.spm.spatial.normalise.write.woptions.vox    = [1 1 1];
    matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
    matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'w';
    
    spm_jobman('run',matlabbatch);
%}

% Reset for the functional data.

    setDefaultsSPM;
    
    matlabbatch = {};
    
% Collect all the (realigned/unwarped) functional scans, including the mean
% image.

    allEPI_restPre = cellstr(strcat([pwd '/data.functional.rest_pre/'], spm_select('List', [pwd '/data.functional.rest_pre'], '^uf.*nii$')));
    
    allEPI_restPost = cellstr(strcat([pwd '/data.functional.rest_post/'], spm_select('List', [pwd '/data.functional.rest_post'], '^uf.*nii$')));
    
    meanScan = cellstr(strcat([pwd '/data.functional.mean/'], spm_select('List', [pwd '/data.functional.mean'], '^meanu.*nii$')));
    allEPI_restPre   = [allEPI_restPre; meanScan];
    allEPI_restPost   = [allEPI_restPost; meanScan];
    
    matlabbatch{1}.spm.spatial.normalise.write.subj.def        = cellstr(strcat([pwd '/data.anatomical.hires/'], spm_select('List', [pwd '/data.anatomical.hires/'], '^y.*nii$')));
    matlabbatch{1}.spm.spatial.normalise.write.subj.resample   = allEPI_restPre;
    matlabbatch{1}.spm.spatial.normalise.write.woptions.bb     = [-78 -112 -70; 78 76 85];
    matlabbatch{1}.spm.spatial.normalise.write.woptions.vox    = [2.4 2.4 2.4];
    matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
    matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'w';
    
    matlabbatch{2}.spm.spatial.normalise.write.subj.def        = cellstr(strcat([pwd '/data.anatomical.hires/'], spm_select('List', [pwd '/data.anatomical.hires/'], '^y.*nii$')));
    matlabbatch{2}.spm.spatial.normalise.write.subj.resample   = allEPI_restPost;
    matlabbatch{2}.spm.spatial.normalise.write.woptions.bb     = [-78 -112 -70; 78 76 85];
    matlabbatch{2}.spm.spatial.normalise.write.woptions.vox    = [2.4 2.4 2.4];
    matlabbatch{2}.spm.spatial.normalise.write.woptions.interp = 4;
    matlabbatch{2}.spm.spatial.normalise.write.woptions.prefix = 'w';
    
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