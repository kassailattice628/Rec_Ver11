function size = getStimSize(dist , figh_size, pixpitch)
% transfrom stimulus size vector [horizontal, vartical] in deg, into pix
size = round(ones(1,2)*Deg2Pix(str2double(get(figh_size,'string')), dist, pixpitch));
end
