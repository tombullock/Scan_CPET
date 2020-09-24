subjects = [101,103,107,109,112,113,115,116,119,121,124,125,127,130,133,135]; % 111
for iSub = 1:length(subjects)
    sjNum = subjects(iSub);
    
    
    for iCon = 1:2
        if iCon == 1
            suffix = 'pre';
        else
            suffix = 'post';
        end
        
        cd(sprintf('/home/bullock/Scan_CPET/Subject_Data/sj%d/results.network.rest',sjNum))
        load(['waveletSeries_' suffix '.mat'])
        
        correlation = bgt_correlationMatrix(waveletSeries,'parametric',0);
        
        correlation_FDR = bgt_correlationFDR(correlation);
        
        movefile('correlation.mat', ['correlation_' suffix '.mat'])
    end
    
end