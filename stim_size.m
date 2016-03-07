function size = stim_size(dist,in)
size = round(ones(1,2)*Deg2Pix(str2double(get(in,'string')), dist));
%{
if get(figUIobj.auto_size,'value')==1
    set(figUIobj.auto_size,'value',0,'string','Auto OFF')
end
%}