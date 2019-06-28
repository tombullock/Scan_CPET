## Notes on freesurfer (these are all terminal commands)


# export the subjects directory

export SUBJECTS_DIR=/home/bullock/Scan_CPET/T1_Freesurfer/T1_Original


# apply the Benson atlas
python3 -m neuropythy atlas --verbose s111

# apply the Benson atlas to multi subs using matlab system command

cd('/home/bullock/Scan_CPET/T1_Freesurfer/T1_Original')

subjects = [101,103,107,109,111,112,113,115,116,119,121,124,125,127,130,133,135];
for i=1:length(subjects)
    sjNum = subjects(i);
    cmd = ['python3 -m neuropythy atlas --verbose s' num2str(sjNum)];
    system(cmd)
end


# apply the retinotopy defined by Benson 2014 to the subject anatomical data

cd('/home/bullock/Scan_CPET/T1_Freesurfer/T1_Original')

subjects = [101,103,107,109,112,113,115,116,119,121,124,125,127,130,133,135]; %111
for i=1:length(subjects)
    sjNum = subjects(i);
    cmd =  ['python3 -m neuropythy benson14_retinotopy --verbose s' num2str(sjNum)];
    system(cmd)
end



# display anatomical data in atlas

freeview -v \
s111/mri/T1.mgz \
s111/mri/wm.mgz \
s111/mri/brainmask.mgz \
s111/mri/benson14_angle.mgz \
s111/mri/benson14_eccen.mgz \
s111/mri/benson14_sigma.mgz \
s111/mri/benson14_varea.mgz \
s111/mri/aseg.mgz:colormap=lut:opacity=0.2 \
s111/scanner.benson14_varea.mgz \
-f \
s111/surf/lh.white:edgecolor=blue \
s111/surf/lh.pial:edgecolor=red \
s111/surf/rh.white:edgecolor=blue \
s111/surf/rh.pial:edgecolor=red 



freeview -v \
s101/mri/T1.mgz \
s101/mri/wm.mgz \
s101/mri/brainmask.mgz \
s101/mri/benson14_angle.mgz \
s101/mri/benson14_eccen.mgz \
s101/mri/benson14_sigma.mgz \
s101/mri/benson14_varea.mgz \
s101/mri/aseg.mgz:colormap=lut:opacity=0.2 \
-f \
s101/surf/lh.white:edgecolor=blue \
s101/surf/lh.pial:edgecolor=red \
s101/surf/rh.white:edgecolor=blue \
s101/surf/rh.pial:edgecolor=red 


# convert the freesurfer oriented mgz into the orientation of my original T1 anatomical scan

(must CD to subject dir first)

mri_convert -rl mri/rawavg.mgz mri/benson14_varea.mgz \scanner.benson14_varea.mgz


                     
                     
 addpath(genpath('sw/freesurfer/matlab'))
 
 
 # try using bbregister
     
 
     
 
                     
                     


