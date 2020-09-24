function jacobs28andMe_estimateMTD_Jordan(sjNum)
% Dynamic connectivity via multiplication of temporal derivatives.
%
% FORMAT jacobs28andMe_estimateMTD(whichDays)
%
% REQUIRED INPUT:
%   whichDays
%       Cell array of strings designating which days of the experiment to
%       estimate MTD.
%
% OUTPUT:
%   No explicit output. If whichDays were entered as an array of study
%   days, obtain a result of dynamic connectivity per session
%   (dynamicConnectivity.mat).
%__________________________________________________________________________
%
% This function will estimate dynamic functional connectivity via
% muliplication of temporal derivatives (Shine et al., 2015, 2016). Note
% that there are certain fixed parameters (e.g. window length, which
% approximates a lowpass filter of ~10s (0.10 Hz). This is adjustable given
% the TR of your sequence for data acquisition (TR * wLength).
%__________________________________________________________________________
% Author:
%   Tyler Santander (t.santander@psych.ucsb.edu)
%   Institute for Collaborative Biotechnologies
%   Department of Psychological & Brain Sciences
%   University of California, Santa Barbara
%   August 2019
%__________________________________________________________________________


% Preliminary setup.
%--------------------------------------------------------------------------

parentDir = '/home/bullock/Scan_CPET/Subject_Data/';

% Loop over study days and estimate dynamic connectivity via MTD.
%--------------------------------------------------------------------------

for iSess = 1:2
    
    if iSess == 1
        suffix = '_pre';
    elseif iSess == 2
        suffix = '_post';
    end
    
    fprintf(['|| Estimating dynamic connectivity for Session: %d \n', iSess]);
    
    tic
    
    % Jump into the resting network directory.
    
    cd([parentDir 'sj',num2str(sjNum), '/results.network.rest']);
    
    % Load the wavelet series, get relevant dimensions.
    
    load(['waveletSeries' suffix '.mat'], 'waveletSeries');
    
    [nTR, nROI] = size(waveletSeries);
    
    % Calculate temporal derivative (simple first-order differencing).
    
    dx = diff(waveletSeries);
    
    % Standardize data.
    
    dxZ = dx .* repmat(std(dx), size(dx,1), 1);
    
    % Compute the functional coupling score.
    
    disp('|| Obtaining functional coupling score...');
    
    fc = bsxfun(@times, permute(dxZ,[1,3,2]), permute(dxZ,[1,2,3]));
    
    % Apply simple moving average to smooth out the estimates in time,
    % given a window length parameter.
    
    disp('|| Smoothing in time...');
    
    mtd     = zeros(nROI, nROI, nTR-1);
    wLength = 14;
    
    for iROI = 1:nROI
        
        for jROI = 1:nROI
            
            mtd(iROI,jROI,:) = smooth(squeeze(fc(:,iROI,jROI)), wLength);
            
        end
        
    end
    
    % Clean up zeros (due to differentiation and smoothing) and save.
    
    mtd(:,:,nTR-round(wLength/2):end) = [];
    mtd(:,:,1:round(wLength/2))       = [];
    
    dynamicConnectivity = mtd;
    
    save(['dynamicConnectivity2' suffix], 'dynamicConnectivity');
    
    
    
    disp(['|| Dynamic connectivity estimated in ' num2str(toc) 'minutes']);
    
    % Navigate back to the parent directory.
    
    cd(parentDir);
    
end

end

