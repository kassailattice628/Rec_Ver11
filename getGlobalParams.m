function params = getGlobalParams
% take disable global variables and save in base work space

%global figUIobj
% figure handles cannot be used after close figures.
global figUIparams
global recobj
global sobj
global RecData

params = cell(1,4);
if isstruct(figUIparams)
    params{1,1} = figUIparams;
end

if isstruct(recobj)
    params{1,2} = recobj;
end

if isstruct(sobj)
    params{1,3} = sobj;
end

if isstruct(RecData)
    params{1,4} = RecData;
end

end
