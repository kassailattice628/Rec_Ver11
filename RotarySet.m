function RotarySet(hObject, ~)
% open plot window for Angular position from Rotary Encoder

global FigRot
switch get(hObject,'value')
    case 0 % close Rotary plot window
        set(hObject,'string','Rotary OFF','BackGroundColor',[0.701961 0.701961 0.701961])
        if ishandle(FigRot.f2)
            close(FigRot.f2)
        end
    case 1 % if ON, open Rotary traces
        set(hObject,'string','Rotary ON','BackGroundColor','g');
        if isfield(FigRot,'f2')
            if ishandle(FigRot.f2)
                figure(FigRot.f2)
            else
                FigRot = openFigRot;
            end
        else
            FigRot = openFigRot;
        end
end
    function hGui = openFigRot
        hGui.f2 = figure('Position',[400, 500, 650, 200], 'Name','RotoryEncoder','Menubar','none', 'Resize','off');
        set(hGui.f2,'DeleteFcn', @RotaryOff);
        hGui.pRot = plot(NaN,NaN);
        title('Rotary Encoder');
        xlabel('Time (s)');
        ylabel('Angle pos.(deg)');
    end
end

function RotaryOff(~,~)
global figUIobj
set(figUIobj.RotCtr, 'value', 0 ,'string','Rotary OFF','BackGroundColor',[0.9400 0.9400 0.9400])%default Mac

end
