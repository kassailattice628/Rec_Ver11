function RotarySet(hObject, ~)
global sRot
global figUIobj
global recobj

switch get(hObject,'value')
    case 0% OFF
        set(hObject,'string','Rotary OFF','BackGroundColor',[0.701961 0.701961 0.701961])
        if ishandle(figUIobj.f2)
            close(figUIobj.f2)
        end
    case 1% if ON, open Rotary traces
        set(hObject,'string','Rotary ON','BackGroundColor','g');
        sRot.DurationInSeconds = recobj.rect/1000; %ms
        if isfield(figUIobj,'f2')
            if ishandle(figUIobj.f2)==1
                figure(figUIobj.f2)
            else
                FigRot
            end
        else
            FigRot
        end
end
    function FigRot
        figUIobj.f2 = figure('Position',[400, 500, 500, 200], 'Name','RotoryEncoder','Menubar','none');
        figUIobj.yRot = recobj.dataall(:,1);
        figUIobj.tRot = recobj.rectaxis/1000;
        figUIobj.pRot = plot(figUIobj.tRot,figUIobj.yRot, 'XdataSource','figUIobj.tRot','YDataSource','figUIobj.yRot');
        title('Rotary Encoder');
        xlabel('Time (s)');
        ylabel('Angle pos.(deg)');
    end
end


