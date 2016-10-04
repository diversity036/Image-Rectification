function [rectI, H] = rectifyImage(filename, debug)

im = imread(filename);
imshow(im);
[d, fname] = fileparts(filename);
% get input
if (debug == 1)
    input = ginput(8);
else
    input = load(fullfile(strrep(d, '/images', '/data'), [fname '.mat']),'input');
end

% convert to homogenous
h_input = [input ones(8,1)];
% lines
line1 = cross(h_input(1,:), h_input(2,:));
line2 = cross(h_input(3,:), h_input(4,:));
line3 = cross(h_input(5,:), h_input(6,:));
line4 = cross(h_input(7,:), h_input(8,:));
% normalize lines
% line1 = line1/line1(3);
% line2 = line2/line2(3);
% line3 = line3/line3(3);
% line4 = line4/line4(3);
% vanishing points
vp1 = cross(line1, line2);
vp2 = cross(line3, line4);
% normalize points
vp1 = vp1/vp1(3);
vp2 = vp2/vp2(3);
% vanishing line
vl = cross(vp1, vp2);

% calc ha
Ha = eye(3);
Ha(3,:) = vl;
% apply ha
newimg = applyH(im, Ha);
imshow(newimg)
% get new input
if (debug == 1)
    new_input = ginput(6);
else
    new_input = load(fullfile(strrep(d, '/images', '/data'), [fname '.mat']),'new_input');
end

h_new_input = [new_input ones(6,1)];
% lines
line1 = cross(h_new_input(1,:), h_new_input(2,:));
line2 = cross(h_new_input(2,:), h_new_input(3,:));
line3 = cross(h_new_input(4,:), h_new_input(5,:));
line4 = cross(h_new_input(5,:), h_new_input(6,:));
% m
m = [];
m = [m; line1(1)*line2(1), line1(1)*line2(2)+line1(2)*line2(1), line1(2)*line2(2);line3(1)*line4(1), line3(1)*line4(2)+line3(2)*line4(1), line3(2)*line4(2)];
% null space of m
s = null(m);
s = s/s(3);
S = [s(1) s(2); s(2), s(3)];
[U, D, V] = svd(S);

affineH = inv([U*sqrt(D)*V' zeros(2,1); 0 0 1]);
rectI = applyH(newimg, affineH);
H = affineH*Ha;
imshow(rectI);
if (debug == 1)
    save(fullfile(strrep(d, '/images', '/data'), [fname '.mat']),'input','new_input');
end

end


