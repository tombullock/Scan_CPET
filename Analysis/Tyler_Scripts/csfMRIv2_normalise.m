function csfMRIv2_normalise(nRun, hiresSeq)

% Initialize default SPM configurations for fMRI.

    setDefaultsSPM;
    
    matlabbatch = {};
    
% Normalise the (skull-stripped, bias-corrected) hires first.

    matlabbatch{1}.spm.spatial.normalise.write.subj.def        = cellstr(strcat([pwd '/data.anatomical.' hiresSeq '/'], spm_select('List', [pwd '/data.anatomical.' hiresSeq], '^y.*nii$')));
    matlabbatch{1}.spm.spatial.normalise.write.subj.resample   = cellstr(strcat([pwd '/data.anatomical.' hiresSeq '/'], spm_select('List', [pwd '/data.anatomical.' hiresSeq], '^ss-mt1.*nii$')));
    matlabbatch{1}.spm.spatial.normalise.write.woptions.bb     = [-78 -112 -70; 78 76 85];
    matlabbatch{1}.spm.spatial.normalise.write.woptions.vox    = [1 1 1];
    matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
    matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'w';
    
    spm_jobman('run',matlabbatch);


% Reset for the functional data.

    setDefaultsSPM;
    
    matlabbatch = {};
    
% Collect all the (realigned/unwarped) functional scans, including the mean
% image.

    allEPI = cellstr(strcat([pwd '/data.functional.rest/'], spm_select('List', [pwd '/data.functional.rest'], '^urun.*nii$')));
    
    for iRun = 1:nRun
        
        scans  = cellstr(strcat([pwd '/data.functional.run' num2str(iRun) '/'], spm_select('List', [pwd '/data.functional.run' num2str(iRun)], '^urun.*nii$')));
        
        allEPI = [allEPI; scans];
        
    end
    
    meanScan = cellstr(strcat([pwd 'data.functional.mean/'], spm_select('List', [pwd 'data.functional.mean'], '^meanu.*nii$')));
    allEPI   = [allEPI; meanScan];
    
    matlabbatch{1}.spm.spatial.normalise.write.subj.def        = cellstr(strcat([pwd '/data.anatomical.' hiresSeq '/'], spm_select('List', [pwd '/data.anatomical.' hiresSeq], '^y.*nii$')));
    matlabbatch{1}.spm.spatial.normalise.write.subj.resample   = allEPI;
    matlabbatch{1}.spm.spatial.normalise.write.woptions.bb     = [-78 -112 -70; 78 76 85];
    matlabbatch{1}.spm.spatial.normalise.write.woptions.vox    = [2.4 2.4 2.4];
    matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
    matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'w';
    
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