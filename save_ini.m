function SaveOBJCELL = save_ini

SaveOBJCELL = cell(1,4);
%recobj, sobj, figUIobj, others

%{
save.RecordingTimeSec = []; %recobj.rect
save.SamplingFreqKHz = []; %recobj.sampf
save.SaveMode = []; %get(figUIobj.savech,'value'), recorded channel from RecData(:,2:6); 2:AI1, 3AI2, 4:AI3=PhotoSensor, 5:AI4=TriggerMonitor, 6:RotaryEncodeer
save.CycleNum = []; %recobj.cycleNum
save.VisualStimONOFF = []; %get(figUIobj.stim,ÅevalueÅf)


save.MonitorDiv = []; %sobj.divnum
save.StimColor = []; %sobj.stimcol
save.BackGroundColor = []; %sobj.bgcol

save.StimPattern = []; %get(figUIobj.pattern,ÅestringÅf)

save.pixpitch = []; %sobj.pixpitch;
save.MonitorDist = []; %sobj.monitordist

save.Stim1PositionInDivMatrix = []; %sobj.position
save.Stim1Shape = []; %get(figUIobj.shape,ÅestringÅf)
save.Stim1Size1 = []; %sobj.stimsz(1)
save.Stim1Size2 = []; %sobj.stimsz(2)
save.Stim1DurationMS = []; %sboj.duration

save.Stim1PositionLeftPixel = sobj.position_cord(1);
save.Stim1PositionTopPixel = sobj.position_cord(2);
save.Stim1PositionRightPixel = sobj.position_cord(3);
save.Stim1PositionBottomPixel = sobj.position_cord(4);

save.ShiftDirectionMode = []; %sobj.shiftDir, 1:8= 8 directions, 9=8 directions Ordered, 10=8 directions Rnadom, 11=16 directions Random
save.ShiftAngl = []; %sobj.angle
save.GratingSpatialFreq = []; %sobj.gratFreq2
save.ShiftSpeed = []; %sobj.shiftSpd2

%%%%%%%%%%
save.Stim2Shape = []; %get(figUIobj.shape2,ÅestringÅf)
save.Stim2Size1 = []; %sobj.stimsz2(1)
save.Stim2Size2 = []; %sobj.stimsz2(2)
save.Stim2DurationMS = []; %sboj.duration

save.Stim1PositionLeftPixel = sobj.position_cord(1);
save.Stim1PositionTopPixel = sobj.position_cord(2);
save.Stim1PositionRightPixel = sobj.position_cord(3);
save.Stim1PositionBottomPixel = sobj.position_cord(4);
%}
