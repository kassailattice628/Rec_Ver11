function steppulse(hObject,~, hGui)
global recobj

switch get(hObject,'value');
    case 0
        set(hObject,'BackGroundColor',[0.701961 0.701961 0.701961]);
        set(hGui.Vstart,'BackGroundColor','w')
        set(hGui.Vend,'BackGroundColor','w')
        set(hGui.Vstep,'BackGroundColor','w')
        set(hGui.Cstart,'BackGroundColor','w')
        set(hGui.Cend,'BackGroundColor','w')
        set(hGui.Cstep,'BackGroundColor','w')
        
    case 1;
        set(hObject,'BackGroundColor','g');
        switch recobj.plot
            case 1
                set(hGui.Vstart,'BackGroundColor','w')
                set(hGui.Vend,'BackGroundColor','w')
                set(hGui.Vstep,'BackGroundColor','w')
                set(hGui.Cstart,'BackGroundColor','g')
                set(hGui.Cend,'BackGroundColor','g')
                set(hGui.Cstep,'BackGroundColor','g')
            case 2
                set(hGui.Vstart,'BackGroundColor','g')
                set(hGui.Vend,'BackGroundColor','g')
                set(hGui.Vstep,'BackGroundColor','g')
                set(hGui.Cstart,'BackGroundColor','w')
                set(hGui.Cend,'BackGroundColor','w')
                set(hGui.Cstep,'BackGroundColor','w')
        end
end