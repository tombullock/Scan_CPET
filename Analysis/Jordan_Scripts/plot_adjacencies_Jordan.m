T = readtable('/home/garrett/Scan_CPET/Analysis/Tyler_Scripts/jacobs28andMe_compositeAtlas_nodeIDs.csv');

% Global labels
% 1-24, 201-223 = Visual, 25-59, 224-258 = Somatomotor, 60-85, 259-284 = Dorsal Attention, 86-108, 285-312=
% Salience Ventral Attention, 109-120, 313-324 = Limbic, 121-148,325-357 =
% Control, 149-194, 358-390 = DMN, 195-200,391-400 = Temporal Parietal,
% 401-415 = Subcort
                 
global_nodeIdx = [1:24,201:223,25:59,224:258,60:85,259:284,...
    86:108,285:312,109:120,313:324,121:148,325:357,149:194,358:390,195:200,391:415]';

load('coherence_pre.mat')
pre = coherence.FDR.associationMatrix;

load('coherence_post.mat')
post = coherence.FDR.associationMatrix;

clear coherence

pre_global_sortAdj = pre(global_nodeIdx,global_nodeIdx);

post_global_sortAdj = post(global_nodeIdx,global_nodeIdx);

subplot(1,2,1)
imagesc(pre_global_sortAdj)
xticks([1,24,47,82,117,143,169,195,220,232,244,275,305,345,384,392,400,408,415])
xtickangle(45)
yticks([1,24,47,82,117,143,169,195,220,232,244,275,305,345,384,392,400,408,415])
xticklabels({'','Visual','','SomatoMotor','','Dors Att','','Sal Vent Att',...
    '','Limbic','','Control','','DMN','','TempPar','','SubCort',''})
yticklabels({'','Visual','','SomatoMotor','','Dors Att','','Sal Vent Att',...
    '','Limbic','','Control','','DMN','','TempPar','','SubCort',''})
title('Pre')
set(gca, 'TickDir','out')

subplot(1,2,2)
imagesc(post_global_sortAdj)
xticks([1,24,47,82,117,143,169,195,220,232,244,275,305,345,384,392,400,408,415])
xtickangle(45)
yticks([1,24,47,82,117,143,169,195,220,232,244,275,305,345,384,392,400,408,415])
xticklabels({'','Visual','','SomatoMotor','','Dors Att','','Sal Vent Att',...
    '','Limbic','','Control','','DMN','','TempPar','','SubCort',''})
yticklabels({'','Visual','','SomatoMotor','','Dors Att','','Sal Vent Att',...
    '','Limbic','','Control','','DMN','','TempPar','','SubCort',''})
set(gca, 'TickDir','out')
title('Post')

