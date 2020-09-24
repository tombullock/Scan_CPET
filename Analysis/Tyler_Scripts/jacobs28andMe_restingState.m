function jacobs28andMe_restingState(whichDays)

% How many days worth of data are we trying to cover?

    nSessions = length(whichDays);
    
% Start the clock so we can track overall computation time.

    procStart = tic;
    
% Begin looping over sessions...
    
    disp(' ');
    
    parentDir = pwd;
    
    for iDay = 1:nSessions
        
        dayID = whichDays{iDay};
        
        disp(['|| Running day: ' dayID '. Please wait...']);
        
        cd(dayID);
        
        restingDir = [pwd '/data.functional.rest_pre'];
        
        % Create a new directory in which to store the results, copy over
        % data and navigate into it.
        
        mkdir('results.network.rest');
        cd('results.network.rest');
        
        %unix(['mv ' restingDir '/' spm_select('List', restingDir, '^sruf.*nii.gz$') ' ' pwd '/rest4D.nii.gz']);
        unix(['mv ' restingDir '/' spm_select('List', restingDir, '^swufrest_pre.*nii.gz$') ' ' pwd '/rest4D.nii.gz']);
        unix(['cp ' restingDir '/rp_f* ' pwd]);
        unix(['cp ' restingDir '/anat* ' pwd]);
        
        % Scale functional data to grand median of 1000.
        
        bgt_globalNorm([pwd '/' spm_select('List', pwd, '^rest4D.nii.gz$')], 'median');
        
        % Linearly detrend voxelwise timeseries.
        
        %bgt_detrend([pwd '/' spm_select('List', pwd, '^grest4D.nii.gz$')], 0, .720, 1);
        bgt_detrend([pwd '/' spm_select('List', pwd, '^grest4D.nii.gz$')], 0, .400, 1); %change samp rate for Tom's data
        
        % Wavelet despike.
        
        WaveletDespike([pwd '/' spm_select('List', pwd, '^dgrest4D.nii.gz$')], 'dgrest4D');
        
        % Detrend motion parameters / anatomical noise and regress from
        % timeseries.
        
        load('dtMatrix.mat' ,'R');
        load('anatNoise_pre.mat', 'anatNoise_pre');
        
        motionParams = load([pwd '/' spm_select('List', pwd, '^rp.*txt$')]);
        dtMotion     = R'*motionParams;
        dtAnatNoise  = R'*anatNoise_pre;
        
        bgt_regressNuisance([pwd '/' spm_select('List', pwd, '^dgrest4D_wds.nii.gz$')], dtMotion, 'fristonAR1', dtAnatNoise);
        
        % Extract regional timeseries.
        
        [timeSeries] = bgt_extractRegionalTimeseries([pwd '/' spm_select('List', pwd, '^ndgrest4D_wds.nii.gz$')], ...
                        ['/home/bullock/Scan_CPET/Analysis/Tyler_Scripts/' spm_select('List', '/home/bullock/Scan_CPET/Analysis/Tyler_Scripts', '^rcompositeAtlas.nii.gz$')], ...
                        'eigen1');
                    
        % Get relevant frequency band for modwt and decompose.
        
        wavScales  = 4:7;
        %[wavFreqs] = bgt_wavCalc(.720, 6);
        [wavFreqs] = bgt_wavCalc(.400, 8);
        
        freqBand   = [wavFreqs(6,2), wavFreqs(3,3)];
                
        %bgt_modbgt_modwt(timeSeries, .720, wavScales);
        bgt_modwt(timeSeries, .400, wavScales);
        
        
        load([pwd '/waveletSeries.mat'], 'waveletSeries');
        
        % Estimate coherence and apply FDR correction.
        
        %[coherence] = bgt_coherenceMatrix(waveletSeries, .720, freqBand, 'Welch', 'parametric', 0);
        [coherence] = bgt_coherenceMatrix(waveletSeries, .400, freqBand, 'Welch', 'parametric', 0);
        bgt_coherenceFDR(coherence, .05);
        
        % Navigate back to parent directory.
                            
        cd(parentDir); disp(' ');
                    
    end
    
% Display total computation time.

    procEnd = toc(procStart);
    disp(['- Jobs completed for ' num2str(nSessions) ' sessions in ' num2str(procEnd/60) ' minutes -']);
    
end