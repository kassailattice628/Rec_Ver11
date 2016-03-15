function save = get_save_params(recobj, sobj)
%save parameters for Ver11.03
%these paraemters are aupdate in evely loop and saved as Matrix

save.cycleNum = recobj.cycleNum;
save.RecStartTime = recobj.tRec;
save.divnum = sobj.divnum;
%{
%stim1
save.stim1position = sobj.position;
save.stim1size1 = sobj.stimsz(1);
save.stim1size2 = sobj.stimsz(2);
save.stim1duration = sobj.duration;
save.stim1color = sobj.stimcol;
save.stim1PTBOnTime = sobj.tPTBon;
save.stim1PTBOffTime = sobj.tPTBoff;
%save.stim1CenterLeft = stim1_center(1);
%save.stim1CenterBottom = stim1_center(2);

save.zoom_dist = sobj.zoom_dist;
%save.zoom_angle = sobj.zoom_angle;
save.Image_index = sobj.Img_i;

%stim2
save.stim2size1 = sobj.stimsz2(1);
save.stim2size2 = sobj.stimsz2(2);
sobj.stim2color = sobj.stimcol2;
save.stim2PTBOnTime = sobj.tPTBon2;
save.stim2PTBOffTime = sobj.tPTBoff2;
%save.stim2CenterLeft = stim2_center(1);
%save.stim2CenterBottom = stim2_center(2);
%}