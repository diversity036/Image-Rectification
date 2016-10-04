%function [rectI, H] = rectifyImage(filename, debug)
filename = './images/checker1.jpg';
debug = 1;
[d, fname] = fileparts(filename);
if (debug == 0)
    load(fullfile(strrep(d, './images', './data'), [fname '.mat']))
end

im = imread(filename);
figure;
title('original image');
imshow(im);
hold on;
% get input
if (debug == 1)
    input = ginput(8);
end

% convert to homogenous
h_input = [input ones(8,1)];
% lines
line1 = cross(h_input(1,:), h_input(2,:));
line2 = cross(h_input(3,:), h_input(4,:));
line3 = cross(h_input(5,:), h_input(6,:));
line4 = cross(h_input(7,:), h_input(8,:));

line(input(1:2,1), input(1:2,2), 'Color', 'r', 'LineWidth', 6);
line(input(3:4,1), input(3:4,2), 'Color', 'r', 'LineWidth', 6);
line(input(5:6,1), input(5:6,2), 'Color', 'b', 'LineWidth', 6);
line(input(7:8,1), input(7:8,2), 'Color', 'b', 'LineWidth', 6);

% vanishing points
vp1 = cross(line1, line2);
vp2 = cross(line3, line4);
% normalize points
vp1 = vp1/vp1(3);
vp2 = vp2/vp2(3);
% vanishing line
vl = cross(vp1, vp2);

line([vp1(1), vp2(1)],[vp1(2),vp2(2)], 'Color', 'yellow', 'LineWidth', 6)

% calc ha
Ha = eye(3);
Ha(3,:) = vl;
% apply ha
newimg = applyH(im, Ha);
figure;
title('affine image');
imshow(newimg)
hold on
% get new input
if (debug == 1)
    new_input = ginput(9);
end

h_new_input = [new_input ones(9,1)];
% lines
line1 = cross(h_new_input(1,:), h_new_input(2,:));
line2 = cross(h_new_input(2,:), h_new_input(3,:));
line3 = cross(h_new_input(4,:), h_new_input(5,:));
line4 = cross(h_new_input(5,:), h_new_input(6,:));
line5 = cross(h_new_input(7,:), h_new_input(8,:));
line6 = cross(h_new_input(8,:), h_new_input(9,:));

line(new_input(1:2,1), new_input(1:2,2), 'Color', 'r', 'LineWidth', 6);
line(new_input(2:3,1), new_input(2:3,2), 'Color', 'r', 'LineWidth', 6);
line(new_input(4:5,1), new_input(4:5,2), 'Color', 'b', 'LineWidth', 6);
line(new_input(5:6,1), new_input(5:6,2), 'Color', 'b', 'LineWidth', 6);
line(new_input(7:8,1), new_input(7:8,2), 'Color', 'b', 'LineWidth', 6);
line(new_input(8:9,1), new_input(8:9,2), 'Color', 'b', 'LineWidth', 6);
% m
m = [];
m = [m; 
    line1(1)*line2(1), line1(1)*line2(2)+line1(2)*line2(1), line1(2)*line2(2);
    line3(1)*line4(1), line3(1)*line4(2)+line3(2)*line4(1), line3(2)*line4(2); 
    ];

cos_t1 = (line1(1)*line2(1)+ line1(2)*line2(2))/sqrt((line1(1)^2+line1(2)^2)*(line2(1)^2+line2(2)^2));
cos_t2 = (line3(1)*line4(1)+ line3(2)*line4(2))/sqrt((line3(1)^2+line3(2)^2)*(line4(1)^2+line4(2)^2));
cos_t3 = (line5(1)*line6(1)+ line5(2)*line6(2))/sqrt((line5(1)^2+line6(2)^2)*(line5(1)^2+line6(2)^2));
% null space of m
s = null(m);
s = s/s(3);
S = [s(1) s(2); s(2), s(3)];
[U, D, V] = svd(S);

affineH = inv([U*sqrt(D)*V' zeros(2,1); 0 0 1]);
rectI = applyH(newimg, affineH);
H = affineH*Ha;
figure;
title('rectified image');
imshow(rectI);
if (debug == 1)
    save(fullfile(strrep(d, './images', './data'), [fname '.mat']),'input','new_input');
end




