%{
model_runIEM_job
Author: Tom Bullock, UCSB Attention Lab
Date: 10.15.19

%}

clear
close all

subjects = [101,103,107,109,111,112,113,119,121,125,127,130,133,135];

for sjNum=subjects
    
    for thisSession=1:2
        model_runIEM(sjNum,thisSession)
    end
    
end