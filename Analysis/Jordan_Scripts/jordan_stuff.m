for iSub = 1:length(subs)
    sjNum = subs(iSub);
    
    sprintf('Sj %d\n',sjNum)
    cd([current_dir '/sj' int2str(sjNum) '/results.network.rest'])
    ls('*_post.mat')
    ls('*_pre.mat')
end
    