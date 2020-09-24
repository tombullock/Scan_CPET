%{
loops though all subs and plots ***sj111 POST NOT PROCESSED***
%}
subjects = [101,103,107,109,112,113,115,116,119,121,124,125,127,130,133,135]; % 111

for iSub=1:length(subjects)
    sjNum=subjects(iSub);
    thisDir = sprintf('/home/bullock/Scan_CPET/Subject_Data/sj%d/results.network.rest',sjNum);
    figure('units','normalized','outerposition',[0 0 1 1])
    load([thisDir '/' 'coherence_pre.mat'])
    subplot(1,2,1)
    imagesc(coherence.FDR.associationMatrix,[0,.7])
    colorbar
    load([thisDir '/' 'coherence_post.mat'])
    subplot(1,2,2)
    imagesc(coherence.FDR.associationMatrix,[0,.7])
    colorbar
    ylabel(num2str(sjNum))
    pause(5)
    close
end