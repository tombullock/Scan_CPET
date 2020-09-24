function jacobs28andMe_restingState_Jordan(sjNum,iSess)

addpath(genpath('/home/bullock/Scan_CPET/Analysis'))
addpath(genpath('/home/bullock/spm12'))

rmpath('/home/bullock/spm12/external/fieldtrip/external/stats/') %betainv script here causes issues

home_dir = '/home/bullock/Scan_CPET/Subject_Data';

cd([home_dir '/sj' int2str(sjNum)])


% Start the clock so we can track overall computation time.

procStart = tic;

% Begin looping over sessions...

disp(' ');

parentDir = pwd;



disp(['|| Running session: ' int2str(iSess) '. Please wait...']);

if iSess == 1
    suffix = '_pre';
elseif iSess == 2
    suffix = '_post';
end

restingDir = [parentDir '/data.functional.rest' suffix];

% Create a new directory in which to store the results, copy over
% data and navigate into it.

mkdir('results.network.rest');
cd('results.network.rest');

%unix(['mv ' restingDir '/' spm_select('List', restingDir, '^sruf.*nii.gz$') ' ' pwd '/rest4D.nii.gz']);



if exist([restingDir '/swufrest' suffix '4D.nii.gz'],'file') %prevent messing up files
    unix(['mv ' restingDir '/' spm_select('List', restingDir, ['^swufrest' suffix '.*nii.gz$']) ' ' pwd ['/rest4D' suffix '.nii.gz']]);
    rp_filename = split(spm_select('List',restingDir,'^rp_f[1-9]*'),'.');
    unix(['cp ' restingDir '/rp_f* ' [pwd '/' char(rp_filename(1)), suffix, '.txt']]);
    unix(['cp ' restingDir '/anat* ' pwd]);
elseif exist([pwd '/rest4D' suffix '.nii.gz'],'file')
else
    disp('Could not find file')
    return
end


% Scale functional data to grand median of 1000.

bgt_globalNorm([pwd '/' spm_select('List', pwd, ['^rest4D' suffix '.nii.gz$'])], 'median');

% Linearly detrend voxelwise timeseries.

%bgt_detrend([pwd '/' spm_select('List', pwd, '^grest4D.nii.gz$')], 0, .720, 1);
bgt_detrend([pwd '/' spm_select('List', pwd, ['^grest4D' suffix '.nii.gz$'])], 0, .400, 1); %change samp rate for Tom's data

% Wavelet despike.

WaveletDespike([pwd '/' spm_select('List', pwd, ['^dgrest4D' suffix '.nii.gz$'])], 'dgrest4D');

% Detrend motion parameters / anatomical noise and regress from
% timeseries.

movefile('dtMatrix.mat', ['dtMatrix' suffix '.mat']);

load(['dtMatrix' suffix '.mat'] ,'R');
anatNoise = load(['anatNoise' suffix '.mat'], ['anatNoise' suffix]);

if iSess == 1
    anatNoise = anatNoise.anatNoise_pre;
elseif iSess == 2
    anatNoise = anatNoise.anatNoise_post;
end

rp_files = cellstr(spm_select('List', pwd, 'rp*.*txt'));
for iFile=1:length(rp_files)
    if ismember(suffix, rp_files{iFile})
        motionParams = load(rp_files{iFile});
    end
end
dtMotion     = R'*motionParams;
dtAnatNoise  = R'*anatNoise;

movefile('dgrest4D_EDOF.nii.gz', ['dgrest4D' suffix '_EDOF.nii.gz']);
movefile('dgrest4D_SP.txt', ['dgrest4D' suffix '_SP.txt']);
movefile('dgrest4D_wds.nii.gz', ['dgrest4D' suffix '_wds.nii.gz'])
movefile('dgrest4D_noise.nii.gz',['dgrest4D' suffix '_noise.nii.gz'])

bgt_regressNuisance([pwd '/' spm_select('List', pwd, ['^dgrest4D' suffix '_wds.nii.gz$'])], dtMotion, 'fristonAR1', dtAnatNoise);

% Extract regional timeseries.

[timeSeries] = bgt_extractRegionalTimeseries([pwd '/' spm_select('List', pwd, ['^ndgrest4D' suffix '_wds.nii.gz$'])], ...
    ['/home/bullock/Scan_CPET/Analysis/Tyler_Scripts/' spm_select('List', '/home/bullock/Scan_CPET/Analysis/Tyler_Scripts', '^rcompositeAtlas.nii.gz$')], ...
    'eigen1');

movefile('timeSeries.mat', ['timeSeries' suffix '.mat']);
% Get relevant frequency band for modwt and decompose.

wavScales  = 4:7;
%[wavFreqs] = bgt_wavCalc(.720, 6);
[wavFreqs] = bgt_wavCalc(.400, 8);

freqBand   = [wavFreqs(6,2), wavFreqs(3,3)];

%bgt_modbgt_modwt(timeSeries, .720, wavScales);
bgt_modwt(timeSeries, .400, wavScales);

movefile('waveletSeries.mat', ['waveletSeries' suffix '.mat']);

load([pwd '/waveletSeries' suffix '.mat'], 'waveletSeries');

% Estimate coherence and apply FDR correction.

%[coherence] = bgt_coherenceMatrix(waveletSeries, .720, freqBand, 'Welch', 'parametric', 0);
[coherence] = bgt_coherenceMatrix(waveletSeries, .400, freqBand, 'Welch', 'parametric', 0);
bgt_coherenceFDR(coherence, .05);

movefile('coherence.mat', ['coherence' suffix '.mat'])

% Navigate back to parent directory.

cd(parentDir); disp(' ');



% Display total computation time.

procEnd = toc(procStart);
disp(['- Jobs completed for ' suffix(2:end) ' session in ' num2str(procEnd/60) ' minutes -']);

end