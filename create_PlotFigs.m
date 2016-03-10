function create_PlotFigs(hObject, num)
% open Live Plot window 

global FigLive

FigPlotInfo.pos = [400, 270, 650, 200];
FigPlotInfo.name = 'Live Plots';
FigPlotInfo.fignum = num;
FigPlotInfo.title = 'Live Plots';
FigPlotInfo.ylabel = 'TTLs Monitor(V)';

handle = hObject;
create_PlotFig(FigLive, handle, FigPlotInfo);

