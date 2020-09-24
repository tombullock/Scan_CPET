%{
plot_CTFs
Author:Tom Bullock
Date: 07.24.18

% just select the part you want for now (individual or group)
%}

clear 
close all

sourceDir = '/home/bullock/Scan_CPET/IEM_Results';

plotIndividualSubs = 1;

%subjects = 101;
subjects = [101,103,107,109,111,112,113,119,121,125,127,130,133,135];


% compile all subs matrix
for iSub=1:length(subjects)
    sjNum=subjects(iSub);
    for thisSession=1:2
        load([sourceDir '/' sprintf('sj%d_se%02d_allTF.mat',sjNum,thisSession)])
        % masterTF (sub,session,realVsperm,locVsori,chanOffsets)
        masterTF(iSub,thisSession,1,:,:) = realTF;
        masterTF(iSub,thisSession,2,:,:) = permTF;
    end
end

% plot individual subs
if plotIndividualSubs==1
    for iSub=1:size(masterTF,1)
        
        sjNum=subjects(iSub);
        
        h=figure;
        
        subplot(1,2,1)
        plot(squeeze(masterTF(iSub,1,1,1,:)),'color','b','LineWidth',2); hold on  % se01,real,loc
        plot(squeeze(masterTF(iSub,2,1,1,:)),'color','r','LineWidth',2);  % se02,real,loc
        plot(squeeze(masterTF(iSub,1,2,1,:)),'color','b','LineWidth',2,'LineStyle','--'); % se01,perm,loc
        plot(squeeze(masterTF(iSub,2,2,1,:)),'color','r','LineWidth',2,'LineStyle','--');  % se02,perm,loc
        title('Location CTFs')
        
        legend('pre-loc-real','post-loc-real','pre-loc-perm','post-loc-perm','location','north')
        
        subplot(1,2,2)
        plot(squeeze(masterTF(iSub,1,1,2,:)),'color','b','LineWidth',2); hold on  % se01,real,ori
        plot(squeeze(masterTF(iSub,2,1,2,:)),'color','r','LineWidth',2);  % se02,real,ori
        plot(squeeze(masterTF(iSub,1,2,2,:)),'color','b','LineWidth',2,'LineStyle','--'); % se01,perm,ori
        plot(squeeze(masterTF(iSub,2,2,2,:)),'color','r','LineWidth',2,'LineStyle','--');  % se02,perm,ori
        title('Orientation CTFs')
        
        legend('pre-ori-real','post-ori-real','pre-ori-perm','post-ori-perm','location','north')
        
       pause(5)
        
       close
        
    end
end

% plot all subs

h=figure;

subplot(1,2,1)
errorbar(squeeze(mean(masterTF(:,1,1,1,:))),squeeze(std(masterTF(:,1,1,1,:),0,1))./sqrt(size(masterTF,1)),'color','b','LineWidth',2); hold on  % se01,real,loc
errorbar(squeeze(mean(masterTF(:,2,1,1,:))),squeeze(std(masterTF(:,2,1,1,:),0,1))./sqrt(size(masterTF,1)),'color','r','LineWidth',2);  % se02,real,loc
errorbar(squeeze(mean(masterTF(:,1,2,1,:))),squeeze(std(masterTF(:,1,2,1,:),0,1))./sqrt(size(masterTF,1)),'color','b','LineWidth',2,'LineStyle','--'); % se01,perm,loc
errorbar(squeeze(mean(masterTF(:,2,2,1,:))),squeeze(std(masterTF(:,2,2,1,:),0,1))./sqrt(size(masterTF,1)),'color','r','LineWidth',2,'LineStyle','--');  % se02,perm,loc
title(['Location CTFs (n=' num2str(size(masterTF,1)) ')' ])

legend('preVO2-loc-real','postVO2-loc-real','preVO2-loc-perm','postVO2-loc-perm','location','north')

ylabel('BOLD RESPONSE')
xlabel('Channel Offset')
set(gca,'LineWidth',1,'xtick',[1:6],'xticklabel',{'-120','-60 ',' 0  ',' 60 ',' 120', '180 '},'ylim',[-.3,.5],'FontSize',24)

subplot(1,2,2)
errorbar(squeeze(mean(masterTF(:,1,1,2,:))),squeeze(std(masterTF(:,1,1,2,:),0,1))./sqrt(size(masterTF,1)),'color','b','LineWidth',2); hold on  % se01,real,ori
errorbar(squeeze(mean(masterTF(:,2,1,2,:))),squeeze(std(masterTF(:,2,1,2,:),0,1))./sqrt(size(masterTF,1)),'color','r','LineWidth',2);  % se02,real,ori
errorbar(squeeze(mean(masterTF(:,1,2,2,:))),squeeze(std(masterTF(:,1,2,2,:),0,1))./sqrt(size(masterTF,1)),'color','b','LineWidth',2,'LineStyle','--'); % se01,perm,ori
errorbar(squeeze(mean(masterTF(:,2,2,2,:))),squeeze(std(masterTF(:,2,2,2,:),0,1))./sqrt(size(masterTF,1)),'color','r','LineWidth',2,'LineStyle','--');  % se02,perm,ori
title(['Orientation CTFs (n=' num2str(size(masterTF,1)) ')' ])

legend('preVO2-ori-real','postVO2-ori-real','preVO2-ori-perm','postVO2-ori-perm','location','north')

ylabel('BOLD RESPONSE')
xlabel('Channel Offset')
set(gca,'LineWidth',1,'xtick',[1:6],'xticklabel',{'-120','-60 ',' 0  ',' 60 ',' 120', '180 '},'ylim',[-.3,.5],'FontSize',24)




% %% produce a quick plot
% plot(realTF(1,:),'color','r','LineWidth',2); hold on % row1 = location
% plot(realTF(2,:),'color','b','LineWidth',2);         % row2 = orientation
% plot(permTF(1,:),'color','r','LineWidth',2,'LineStyle','--');
% plot(permTF(2,:),'color','b','LineWidth',2,'LineStyle','--');
% 
% legend('loc-real','ori-real','loc-permuted','ori-permuted','location','north')
% ylabel('BOLD RESPONSE')
% xlabel('Channel Offset')
% set(gca,'LineWidth',1,'xtick',[1:6],'xticklabel',{'-120','-60 ',' 0  ',' 60 ',' 120', '180 '},'FontSize',24)