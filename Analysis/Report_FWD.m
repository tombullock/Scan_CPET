%{
Report_FWD (framewise displacement)
Author: Tom Bullock
Date: 12.19.18
%}

clear
close all

destDir = '/home/bullock/Scan_CPET/Data_Compiled';

cd /home/bullock/Scan_CPET/Subject_Data

d=dir('sj*');

for i=1:length(d)
    
    sjNum = str2double(d(i).name(3:end));
    
    load(['sj' num2str(sjNum) '/' 'data.fwd' '/' 'framewiseDisplacement.mat'])
    allFWD(i).sjNum = sjNum;
    allFWD(i).fwd = framewiseDisplacement;
    
    if numel(fieldnames(framewiseDisplacement))==4
        summaryFWD_mean(i,:) = [sjNum,framewiseDisplacement.run1.mean,framewiseDisplacement.run2.mean,framewiseDisplacement.run3.mean,framewiseDisplacement.run4.mean];
        summaryFWD_max(i,:) = [sjNum,framewiseDisplacement.run1.max,framewiseDisplacement.run2.max,framewiseDisplacement.run3.max,framewiseDisplacement.run4.max];
    elseif numel(fieldnames(framewiseDisplacement))==2
        summaryFWD_mean(i,:) = [sjNum,framewiseDisplacement.run1.mean,NaN,framewiseDisplacement.run3.mean,NaN];
        summaryFWD_max(i,:) = [sjNum,framewiseDisplacement.run1.max,NaN,framewiseDisplacement.run3.max,NaN];
    end
end

save([destDir '/' 'Framewise_Displacement.mat'],'allFWD','summaryFWD_mean','summaryFWD_max')

%% pairwise comparisons (mean FWD) - task pre vs. task post, and rest pre vs. rest post

disp('compare rest pre vs. post exercise')
[h,p,ci,stats] = ttest(summaryFWD_mean(:,2),summaryFWD_mean(:,4))
disp('compare task pre vs. post exercise')
[h,p,ci,stats] = ttest(summaryFWD_mean(:,3),summaryFWD_mean(:,5))