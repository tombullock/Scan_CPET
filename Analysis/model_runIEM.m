%{
IEM_fMRI_VO2
Author: Tom Bullock
Date: 07.21.18
%}

%%clear
%%close all

function model_runIEM(sjNum,thisSession)

%% set dirs
sourceDirData = '/home/bullock/Scan_CPET/Single_Trial_Data';
sourceDirMask = '/home/bullock/Scan_CPET/Benson_Visual_Cortex_Masks';
destDir = '/home/bullock/Scan_CPET/IEM_Results';

% % %% subject/session
% % sjNum=119;
% % thisSession = 1;


%% seed rng
for rngShuffle =1:100
    rng('shuffle')
end

%% define basis function
basisFunction=0; %0=graded, 1=delta
nBF=6; %set number of basis functions
shiftFactor = round(nBF/2); %ensure it works for even and odd number of BF
tbasis = [sind(0:30:150)].^7;  % creates the sin basis function

%% load single trial data
load([sourceDirData '/' sprintf('sj%d_se%02d_single_trial.mat',sjNum,thisSession)])


%% load visual cortex mask
load([sourceDirMask '/' sprintf('sj%d_vis_cort_mask_benson.mat',sjNum)],'voxelMatMask')

%% isolate visual cortex voxels using mask
voxelMat=voxelMat(:,find(voxelMatMask>0));



%% isolate orientation and location trials in the run (and remove target repeat trials) (col1: cond1=loc,cond2=ori, col5=ori,col6=loc)
cntLoc=0; cntOri=0;
for iTrial = 1:size(allTrialsMat,1)
    if allTrialsMat(iTrial,1)==1 && allTrialsMat(iTrial,7)~=1  % if location condition and not a targ repeat
        cntLoc=cntLoc+1;
        locTrialMat(cntLoc,:) = allTrialsMat(iTrial,:);
        locTrialVoxelMat(cntLoc,:) = voxelMat(iTrial,:);
    end
    if allTrialsMat(iTrial,1)==2 && allTrialsMat(iTrial,7)~=1 % if orientation condition and not a targ repeat
        cntOri=cntOri+1;
        oriTrialMat(cntOri,:) = allTrialsMat(iTrial,:);
        oriTrialVoxelMat(cntOri,:) = voxelMat(iTrial,:);
    end
end

%% run IEM on both location (1) and orientation (2) experiments
realTF = [];
permTF = [];
for permuteConditionLabels=1:2 %1=real,2=perm
    for tfType=1:2
        
        % clear some vars
        thisTrialMat = [];
        thisVoxelMat = [];
        call = [];
        actual = [];
        C1 = [];
        snrdata = [];
        tpart = [];
        tWeights = [];
        thistf = [];
        centeredC1 = [];
        centeredtf = [];
        
        
        % select data
        if tfType==1
            thisTrialMat = locTrialMat(:,6);
            thisVoxelMat = locTrialVoxelMat;
        else
            thisTrialMat = oriTrialMat(:,5);
            thisVoxelMat = oriTrialVoxelMat;
        end
        
        % remove NaN values (columns, presumably non-brain space?) from matrix
        thisVoxelMat( :, all( isnan( thisVoxelMat ), 1 ) ) = [];
        
        
        %% IEM settings
        if permuteConditionLabels==1
            permtest=0; % real IEM
        else
            permtest=1; % perm IEM
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
        for t=1:size(thisTrialMat,1)
            actual = [actual,thisTrialMat(t)];
            C1(t,:) = call(thisTrialMat(t),:);
        end
        
        %if you want to prove to yourself that this might be real, set permtest
        %to 0, this will shuffle trial bin assignment
        if permtest ==1
            disp('PERMUTE LABELS')
            tmp = randperm(length(actual));
            C1 = C1(tmp,:);
        end
        
        %cvpartition is a function that facilitates the cross validation of the
        %estimation 'Leaveout' leaves one trial out per iteration and trains on the rest
        %could do K-fold where the number of trials left out is equal to
        %ntrials/numfolds. see help for cvpartition for more info
        
        %% TEMP
        snrdata = thisVoxelMat;
        
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
        
        % average over trials to get final CTF
        if permuteConditionLabels==1
            realTF(tfType,:) = mean(centeredtf);
        else
            permTF(tfType,:) = mean(centeredtf);
        end
        
    end
end

save([destDir '/' sprintf('sj%d_se%02d_allTF.mat',sjNum,thisSession)],'realTF','permTF')

end

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