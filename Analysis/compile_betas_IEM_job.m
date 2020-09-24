%subjects = [112,119,121,125,127,130,133]; % already processed sj list (with FL)
%subjects = [101,103,107,109,111,112,113,119,121,125,127,130,133,135]; % not all processed (14th oct 2019)
subjects = [101,103,107,109,111,113,135];

for sjNum=subjects
    for thisSession=1:2
        compile_betas_IEM(sjNum,thisSession)
    end
end