%subjects = [101,103,107,109,112,113,115,116,119,121,124,125,127,130,133,135];

subjects = 101;
parentDir = '/home/bullock/Scan_CPET/Subject_Data/';


for iSub = 1:length(subjects)
    sjNum = subjects(iSub);
    
    cd([parentDir 'sj' num2str(sjNum) '/results.network.rest'])
    
    for iSess = 1:2
        
        if iSess == 1
            suffix = '_pre';
        elseif iSess == 2
            suffix = '_post';
        end
        
        load(['waveletSeries' suffix '.mat'])
        
        nROIs = size(waveletSeries,2);
        
        TR = .4; %400ms
        sampFreq = 1/TR;
        scan_length = size(waveletSeries,1)/sampFreq; %seconds
        
        time = linspace(0,scan_length,size(waveletSeries,1));
        
        % 2 second sliding window of increments of 1 seconds
        window = [0 2]; step_size = 1;
        
        nWindows = max(time)-1;
        
        %empty cell array to store connectivity matrices. cell array for
        %genLouvain
        all_associationMatrices = cell(max(time)-1,1); p_vals = all_associationMatrices;
        corrected_associationMatrix = cell(max(time)-1,1);
        
        dFC = [];
        
        tic
        
        i = 1;
        while window(2) <= max(time)
            
            
            current_associationMatrix = zeros(nROIs,nROIs);
            
            window_idx = [find(abs(time-window(1))==min(abs(time-window(1)))):find(abs(time-window(2))==min(abs(time-window(2))))];
            for iROIi = 1:nROIs
                for iROIj = 1:nROIs
                    
                    if iROIi ~= iROIj %ignore diagonal
                        
                        [corr,p] = corrcoef(waveletSeries(window_idx,iROIi),waveletSeries(window_idx,iROIj));
                        
                        corr_coef = corr(~tril(ones(size(corr)))); %take upper triangle of symmetric matrix
                        current_associationMatrix(iROIi,iROIj) = corr_coef;
                    end
                end
            end
            
            
            all_associationMatrices{i} = current_associationMatrix;
            p_vals{i} = p;
            
            %FDR correction for correlations
            pVect = p(~tril(ones(size(p))));
            pFDR = fdr(pVect,0.5,'parametric');
            
            current_associationMatrix(p > pFDR)= 0;
            corrected_associationMatrix{i} = current_associationMatrix;
            
            
            i=i+1;
            
            window = window + step_size;
        end
        
        toc
        
        dFC.uncorrected_coh = all_associationMatrices;
        dFC.pVals = p_vals;
        dFC.corrected_FDRcoh = corrected_associationMatrix;
        
        
        save(['dFC' suffix '.mat'],'dFC')
    end
    
end
