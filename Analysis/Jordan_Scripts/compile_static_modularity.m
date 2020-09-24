%{
loops though all subs and plots ***sj111 POST NOT PROCESSED***
%}
subjects = [101,103,107,109,112,113,115,116,119,121,124,125,127,130,133,135]; % 111

type = 2; %1: coherence 2: correlation

outDir = '/home/bullock/Scan_CPET/Data_Compiled/';

allpre_mod = zeros(length(subjects),1); %sj x 1 
allpre_assign = []; %sjs x nodes
allpost_mod = zeros(length(subjects),1); allpost_assign =[];

% compile adjacency matrices into cell array for categorical multilayer
% modularity
allpre_adjacencies = {}; allpost_adjacencies = {}; 

for iSub=1:length(subjects)
    sjNum=subjects(iSub);
    thisDir = sprintf('/home/bullock/Scan_CPET/Subject_Data/sj%d/results.network.rest',sjNum);
    
    if type == 1
        pre = load([thisDir '/' 'coherence_pre.mat']);
        pre_con = pre.coherence.FDR.associationMatrix;
        
        post = load([thisDir '/' 'coherence_post.mat']);
        post_con = post.coherence.FDR.associationMatrix;
    else
        pre = load([thisDir '/' 'correlation_pre.mat']);
        pre_con = abs(pre.correlation.FDR.associationMatrix);
        pre_con(isnan(pre_con)) = 0;
        
        post = load([thisDir '/' 'correlation_post.mat']);
        post_con = abs(post.correlation.FDR.associationMatrix);
        post_con(isnan(post_con)) = 0;
    end
    
    %use GenLouvain for first past analysis on static fc
    k_pre = full(sum(pre_con));
    twom_pre = sum(k_pre);
    gamma = 1.1; %resolution parameter. gamma < 1 results in small modules, gamma > 1 results in larger modules
    
    B_pre = @(i) pre_con(:,i) - gamma*k_pre'*k_pre(i)/twom_pre;
    
    [S_pre, Q_pre] = iterated_genlouvain(B_pre);
    Q_pre = Q_pre/twom_pre;
    
    allpre_assign(iSub,:) = S_pre;
    allpre_mod(iSub) = Q_pre;
    
    k_post = full(sum(post_con));
    twom_post = sum(k_post); %sum of all the edge weights
    
    B_post = @(i) post_con(:,i) - gamma*k_post'*k_post(i)/twom_post;
    
    [S_post, Q_post] = iterated_genlouvain(B_post);
    Q_post = Q_post/twom_post;
    
    allpost_assign(iSub,:) = S_post;
    allpost_mod(iSub) = Q_post;
    
    % cell array of all adjacency matrices
    allpre_adjacencies{iSub} = pre_con;
    allpost_adjacencies{iSub} = post_con;
    
end

if type == 1
    save([outDir 'pre_staticAdj_coh.mat'], 'allpre_adjacencies')
    save([outDir 'post_staticAdj_coh.mat'], 'allpost_adjacencies')
else
    save([outDir 'pre_staticAdj_cor.mat'], 'allpre_adjacencies')
    save([outDir 'post_staticAdj_cor.mat'], 'allpost_adjacencies')
end

bar([mean(allpre_mod),mean(allpost_mod)])

%% categorical multilayer modularity 

A = allpre_adjacencies;
gamma = 1.1; %resolution parameter

%interlayer coupling parameter that determines the consistency of modules
%across layers (or subjects in this case). Small values emphasize community
%structures unique to the subject, large values emphasize modules shared by
%the entire cohort. 
omega = .4; 

N=length(A{1});
T=length(A);
ii=[]; jj=[]; vv=[];
twomu=0;
for s=1:T
    indx=[1:N]'+(s-1)*N;
    [i,j,v]=find(A{s});
    ii=[ii;indx(i)]; jj=[jj;indx(j)]; vv=[vv;v];
    k=sum(A{s});
    kv=zeros(N*T,1);
    twom=sum(k);
    twomu=twomu+twom;
    kv(indx)=k/twom;
    kcell{s}=kv;
end
AA = sparse(ii,jj,vv,N*T,N*T);
clear ii jj vv
kvec = full(sum(AA));
all2all = N*[(-T+1):-1,1:(T-1)];
AA = AA + omega*spdiags(ones(N*T,2*T-2),all2all,N*T,N*T);
twomu=twomu+T*omega*N*(T-1);
B = @(i) AA(:,i) - gamma*kcell{ceil(i/(N+eps))}*kvec(i);
[S,Q] = genlouvain(B);
Q = Q/twomu;
S = reshape(S,N,T); %each nodes community assignment across subjects

consensus_assignment = mode(S);

entropy = []; 
for iNode = 1:size(S,1)
    for k = 1:41
        full_term = [];
        proportion = sum(S(iNode,:) == k)/size(S,2); %fraction of all subjects whose node(i) is assigned to community(k)
        if proportion == 0
            full_term(k) = 0;
        else
            log_term = log2(proportion);
            full_term(k) = proportion * log_term;
        end
    end
    entropy(iNode) = -sum(full_term);
end
entropy_stand = entropy/log2(41);