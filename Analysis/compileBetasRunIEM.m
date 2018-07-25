%{
compileBetasRunIEM
Author: Tom Bullock
Date: 07.24.18
%}

function compileBetasRunIEM(sjNum,thisSession)

% add analysis scripts folder to path
addpath(genpath('/home/bullock/Scan_CPET/Analysis'))

compile_Betas_For_Modeling(sjNum,thisSession)
runIEM_VO2(sjNum,thisSession)

return

