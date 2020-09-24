function jacobs28andMe_estimateAnatomicalNoise(sjNum)

    addpath(genpath('/home/bullock/Scan_CPET/Analysis'))
    addpath(genpath('/home/bullock/spm12'))

% Initialize default SPM configurations for fMRI.

    cd(['/home/bullock/Scan_CPET/Subject_Data/sj',int2str(sjNum)])

    setDefaultsSPM;
    
    matlabbatch = {};
    
% Tell SPM where the hires data live, get the WM and CSF segments.

    hiresPath = [pwd '/data.anatomical.hires'];
    
    whiteSeg = [hiresPath '/' spm_select('List', hiresPath, '^c2s.*nii$')];
    csfSeg   = [hiresPath '/' spm_select('List', hiresPath, '^c3s.*nii$')];
    
    cd('data.anatomical.mask');
    
% Specify inputs to ImCalc and compute mask.

    matlabbatch{1}.spm.util.imcalc.input      = cellstr([whiteSeg; csfSeg]);
    matlabbatch{1}.spm.util.imcalc.output     = 'noisemask.nii';
    matlabbatch{1}.spm.util.imcalc.expression = '(i1 > 0.99) | (i2 > 0.99)';

    matlabbatch{1}.spm.util.imcalc.options.dmtx   = 0;
    matlabbatch{1}.spm.util.imcalc.options.mask   = 0;
    matlabbatch{1}.spm.util.imcalc.options.interp = 0;
    matlabbatch{1}.spm.util.imcalc.options.dtype  = 4;
    
    spm_jobman('run',matlabbatch);
    
% Register mask to mean functional scan.

    meanEPI       = spm_vol(['../data.functional.mean/' spm_select('List', '../data.functional.mean', '^meanuf.*nii$')]);
    noiseMask     = spm_vol([pwd '/noisemask.nii']);
    resliceParams = struct('mean', false, 'interp', 0, 'which', 1, 'prefix', 'r');
    spm_reslice([meanEPI noiseMask], resliceParams);
    
% Navigate to where the resting-state data live.

    cd('../data.functional.rest_pre');
    
% Load in mask and 4D resting data, reshape into 2D.

    rest4D_pre = load_nii([pwd '/ufrest_pre4D.nii.gz']);
    
    cd('../data.functional.rest_post');
     
    rest4D_post = load_nii([pwd '/ufrest_post4D.nii.gz']);
    
    mask3D = load_nii('../data.anatomical.mask/rnoisemask.nii');
    
    [x,y,z,t] = size(rest4D_pre.img);
    rest2D_pre    = reshape(rest4D_pre.img, x*y*z, t);
    rest2D_pre    = double(rest2D_pre)';
    
    [x,y,z,t] = size(rest4D_post.img);
    rest2D_post    = reshape(rest4D_post.img, x*y*z, t);
    rest2D_post    = double(rest2D_post)';
    
    mask2D    = reshape(mask3D.img, 1, numel(mask3D.img));
    
    clear rest4D_pre rest4D_post mask3D
    
% Get WM/CSF voxels, normalize, and SVD.

    disp('|| Extracting first 5 principal components from noise mask');

    noiseData_pre = rest2D_pre(:, logical(mask2D));
    zNoise_pre    = zscore(noiseData_pre); 
    [u_pre,~,~]   = svd(zNoise_pre*zNoise_pre');
    anatNoise_pre = u_pre(:,1:5);
    
    noiseData_post = rest2D_post(:, logical(mask2D));
    zNoise_post    = zscore(noiseData_post); 
    [u_post,~,~]   = svd(zNoise_post*zNoise_post');
    anatNoise_post = u_post(:,1:5);
    
    disp('|| Finished component extraction. Saving...');
    
    cd('../data.functional.rest_pre');
    save anatNoise_pre anatNoise_pre
    
    cd('../data.functional.rest_post');
    save anatNoise_post anatNoise_post
    
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