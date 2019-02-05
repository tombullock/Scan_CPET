%{
compileBetasRunIEM
Author: Tom Bullock
Date: 07.24.18
%}

function wrapper_compile_betas_run_IEM(sjNum,thisSession)

% add analysis scripts folder to path
addpath(genpath('/home/bullock/Scan_CPET/Analysis'))

compile_betas_IEM(sjNum,thisSession)
model_runIEM(sjNum,thisSession)

return

