%==========================================================================
%{
   EEG_runIEM
Author: Tom Bullock, UCSB Attention Lab
Date: 03.14.18

Runs IEM on Kanizsa data

%}
%==========================================================================

% clear all
% close all

function IEM_run_model_fft(thisFilename)

cd /home/bullock/matlab_2016b/TOOLBOXES/eeglab14_1_1b
eeglab
close all
cd /home/bullock/Kanizsa_Oddball/Analysis

% seed rng
for rngShuffle =1:100
    rng('shuffle')
end

% set dirs
spectraProcessedFolder = '/home/bullock/Kanizsa_Oddball/SPECTRA';
compiledDataFolder = '/home/bullock/Kanizsa_Oddball/Data_Compiled';
ctfProcessedFolderEvoked = '/home/bullock/Kanizsa_Oddball/CTFS_EVOKED';
ctfProcessedFolderTotal = '/home/bullock/Kanizsa_Oddball/CTFS_TOTAL';

% cd to spectra folder
% cd '/home/bullock/Kanizsa_Oddball/SPECTRA'

% get files
%d = dir(sprintf('sj%02d*.set',sjNum));
%d = [dir('spectra_sj22*.mat');dir('spectra_sj39*.mat')];

% % cd back to analysis folder
% cd '/home/bullock/Kanizsa_Oddball/Analysis'
% 
% % create vector of filenames
% for i=1:size(d,1)
%     allFiles{i} = d(i).name;
% end

% which basis function
basisFunction=0; %0=graded, 1=delta
nBF=6; %set number of basis functions
shiftFactor = round(nBF/2); %ensure it works for even and odd number of BF
tbasis = [sind(0:30:150)].^7;  % creates the sin basis function

% which TF type?
powerCalcType=1; % 1=evoked, 2=total (1=total w/averagin at end for real)

% load min bin matrix (for trial balancing)
load('/home/bullock/Kanizsa_Oddball/Data_Compiled/minmum_trials_per_bin.mat')

for permuteConditionLabels=1:2 % run real then permuted IEM
    
    % open parallel pool
    %%matlabpool open 8 % old matlab
    
    % start loop through files (make parfor)
    %for i= 1:length(d)
    
    %% clear some vars
    allTF = [];
    trialLocs = [];
    C1=[];
    
    %tmpLoad = load([spectraProcessedFolder '/' d(i).name(1:end-4) '.mat']);
    tmpLoad = load([spectraProcessedFolder '/' thisFilename]);
    chanlocs = tmpLoad.chanlocs;
    freqs = tmpLoad.freqs;
    processLog = tmpLoad.processLog;
    spectra = tmpLoad.spectra;
    trialLocs = tmpLoad.trialLocs;
    
    % find minimum number of trials per bin across all conditions and
    % apply to this IEM run
    sjNum=str2num(thisFilename(11:12));
    if ismember(sjNum,minTrialMat(:,1))
        [~,loc] =ismember(sjNum,minTrialMat(:,1));
        minPerBinAllConds = min(minTrialMat(loc,2:5));
    else
        disp('NOT MEMBER !!!')
    end
    minPerBinAllConds = minPerBinAllConds-1; % subtract 1 so that all bins will have some variability
    
    %for permuteConditionLabels= % run real then permuted IEM
    
    % clear this
    allTF = [];
    
    for iter=1:10 % loop through iterations
        
        % clear vars
        shuffInd=[]; shuffBin=[]; shuffSpectra = []; idx=[]; idxAll=[];
        
        % select trials for this iteration
        shuffInd = randperm(length(trialLocs)); % creates shuffle index
        shuffBin = trialLocs(shuffInd); % shuffled trial locs list
        shuffSpectra = spectra(shuffInd,:,:); % shuffled spectra list
        
        % take the first minPerBinAllConds for each position bin
        for bin=1:6
            idx = find(shuffBin == bin); %get index for shuffled trials belonging to current bin
            idxAll(:,bin) = idx(1:minPerBinAllConds); % drop excess trials
        end
        
        % list of all trials to include in this iteration
        idxAll = idxAll(:);
        
        % select trials for this iteration
        theseTrialLocs = shuffBin(idxAll);
        theseSpectra = shuffSpectra(idxAll,:,:);
        
        
        
        
        
        
        if permuteConditionLabels==1
            permtest=0; % real IEM
        else
            permtest=1; % perm IEM
        end
        
        for thisFreq=1:40
            
            % clear vars
            call = [];
            centeredC1 = [];
            centeredtf = [];
            C1 = [];
            tmp = [];
            tpart = [];
            tWeights = [];
            thistf = [];
            
            % get freq index
            ssvepInd = find(freqs==thisFreq);
            
            % create snrdata matrix just based on FFT power
            snrdata = (theseSpectra(:,:,ssvepInd));
            
            %for total power (do the amp conversion prior to IEM)
            if powerCalcType==2
                snrdata = abs(snrdata).^2;
            end
            
            % what basis function? (0=sin, 1=delta)
            if basisFunction==0
                for b=1:nBF
                    call(b,:) = circshift(tbasis',b-shiftFactor); %adjusted this rather than i-5
                end
            elseif basisFunction==1
                call=eye(6);    % creates delta basis function
            end
            
            %this just loops through and converts the triggers (201-209) to single
            %digit integers that can be used as indices into the basis set function
            actual = [];
            for t = 1:size(theseTrialLocs,1)
                actual = [actual, theseTrialLocs(t,:)];
                C1(t,:) = call(theseTrialLocs(t),:);
            end
            
            %if you want to prove to yourself that this might be real, set permtest
            %to 0, this will shuffle orientation assignment.
            %%permtest =0;
            if permtest ==1;
                tmp = randperm(length(actual));
                C1 = C1(tmp,:);
            end
            
            %cvpartition is a function that facilitates the cross validation of the
            %estimation 'Leaveout' leaves one trial out per iteration and trains on the rest
            %could do K-fold where the number of trials left out is equal to
            %ntrials/numfolds. see help for cvpartition for more info
            tpart = cvpartition(actual,'Leaveout');
            
            for w = 1:tpart.NumTestSets
                
                disp(w);
                %least squares estimate of the weights (note \ is mldivide)
                
                tWeights = C1(tpart.training(w),:)\snrdata(tpart.training(w),:); % gets 8 x 64 mat of tWeights
                
                %check to see if this is the first iteration, if so, then the
                %matrix needs to be allocated, then apply the weights to the test
                %data. this results in the TF for a specific orientation
                if w == 1;
                    thistf = zeros(tpart.NumTestSets,length( (tWeights'\snrdata(tpart.test(w),:)')'));
                end
                thistf(w,:) = (tWeights'\snrdata(tpart.test(w),:)')'; % gets 851 x 6 mat of tfs
                
            end
            
            %center the tuning functions, the middle point then is 0 and the
            %off-entries are "offsets"
            for w = 1:tpart.NumTestSets
                centerind = find(C1(tpart.test(w),:)==1);
                if centerind==shiftFactor
                    centeredC1(w,:) = C1(tpart.test(w),:);
                    centeredtf(w,:) = thistf(w,:);
                else
                    centeredC1(w,:) = circshift(C1(tpart.test(w),:)',shiftFactor-centerind)';
                    centeredtf(w,:) = circshift(thistf(w,:)',shiftFactor-centerind)';
                end
            end
            
            
            % calculate mean CTFs
            if powerCalcType==1
                allTF(thisFreq,iter,:) = [abs(mean(centeredtf))].^2;
            elseif powerCalcType==2
                allTF(thisFreq,iter,:) = mean(centeredtf);
            end
            
        end
        
    end % iteration loop
    
    % average across iterations
    allTF = squeeze(mean(allTF,2));
    
    
    % save tuning functions
    if permuteConditionLabels==1 % real IEM
        if powerCalcType==1
            parsave([ctfProcessedFolderEvoked '/' 'alltf_' thisFilename(9:end-4) '.mat'],allTF,minPerBinAllConds)
        elseif powerCalcType==2
            parsave([ctfProcessedFolderTotal '/' 'alltf_' thisFilename(9:end-4) '.mat'],allTF,minPerBinAllConds)
        end
    else    %permuted IEM
        if powerCalcType==1
            parsave([ctfProcessedFolderEvoked '/' 'alltf_perm_' thisFilename(9:end-4) '.mat'],allTF,minPerBinAllConds)
        elseif powerCalcType==2
            parsave([ctfProcessedFolderTotal '/' 'alltf_perm_' thisFilename(9:end-4) '.mat'],allTF,minPerBinAllConds)
        end
    end
    
    % end % perm loop
    
    
    %end
    
    %%matlabpool close
end

return

