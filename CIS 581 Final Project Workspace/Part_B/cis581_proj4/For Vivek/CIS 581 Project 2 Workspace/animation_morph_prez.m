function[] = animation_morph_prez(do_trig)
load('im_vals_prez.mat');
img_jj = imread(im1);
img_harambe = imread(im2);
img_shrek = imread(im3);

% just for this prez
img_jj = imresize(img_jj, 0.5);
img_harambe = imresize(img_harambe, 0.5);
img_shrek = imresize(img_shrek, 0.5);
im_jj_pts_1 = 0.5 .* im_jj_pts_1;
im_jj_pts_2 = 0.5 .* im_jj_pts_2;
im_harambe_pts_1 = 0.5 .* im_harambe_pts_1;
im_harambe_pts_2 = 0.5 .* im_harambe_pts_2;
im_shrek_pts_1 = 0.5 .* im_shrek_pts_1;
im_shrek_pts_2 = 0.5 .* im_shrek_pts_2;

h = figure(2); clf;
whitebg(h,[0 0 0]);

if do_trig
    fname = 'Project2_eval_prez_trig.avi';
else
    fname = 'Project2_eval_prez_tps.avi';
end
try
    % VideoWriter based video creation
    h_avi = VideoWriter(fname, 'Uncompressed AVI');
    h_avi.FrameRate = 10;
    h_avi.open();
catch
    % Fallback deprecated avifile based video creation
    h_avi = avifile(fname,'fps',10);
end

disp('Generating morphed images...');

w = 0:(1/60):1;
len_w = size(w, 2);
if (do_trig)
    disp('Morphing 1...');
    img_morphed_1 = morph(img_jj, img_harambe, im_jj_pts_1, im_harambe_pts_1, w, w);
    disp('Morphing 2...');
    img_morphed_2 = morph(img_harambe, img_shrek, im_harambe_pts_2, im_shrek_pts_1, w, w);
    disp('Morphing 3...');
    img_morphed_3 = morph(img_shrek, img_jj, im_shrek_pts_2, im_jj_pts_2, w, w);
else
    disp('Morphing 1...');
    img_morphed_1 = morph_tps_wrapper(img_jj, img_harambe, im_jj_pts_1, im_harambe_pts_1, w, w);
    disp('Morphing 2...');
    img_morphed_2 = morph_tps_wrapper(img_harambe, img_shrek, im_harambe_pts_2, im_shrek_pts_1, w, w);
    disp('Morphing 3...');
    img_morphed_3 = morph_tps_wrapper(img_shrek, img_jj, im_shrek_pts_2, im_jj_pts_2, w, w);
end

disp('Completed generating morphed images.');
disp('Adding frames...');

for i=1:15
    imagesc(img_jj);
    axis image; axis off;drawnow;
    try
        % VideoWriter based video creation
        h_avi.writeVideo(getframe(gcf));
    catch
        % Fallback deprecated avifile based video creation
        h_avi = addframe(h_avi, getframe(gcf));
    end
end

for i=1:len_w
    imagesc(img_morphed_1{i});
    axis image; axis off;drawnow;
    try
        % VideoWriter based video creation
        h_avi.writeVideo(getframe(gcf));
    catch
        % Fallback deprecated avifile based video creation
        h_avi = addframe(h_avi, getframe(gcf));
    end
end

for i=1:15
    imagesc(img_harambe);
    axis image; axis off;drawnow;
    try
        % VideoWriter based video creation
        h_avi.writeVideo(getframe(gcf));
    catch
        % Fallback deprecated avifile based video creation
        h_avi = addframe(h_avi, getframe(gcf));
    end
end

for i=1:len_w
    imagesc(img_morphed_2{i});
    axis image; axis off;drawnow;
    try
        % VideoWriter based video creation
        h_avi.writeVideo(getframe(gcf));
    catch
        % Fallback deprecated avifile based video creation
        h_avi = addframe(h_avi, getframe(gcf));
    end
end

for i=1:15
    imagesc(img_shrek);
    axis image; axis off;drawnow;
    try
        % VideoWriter based video creation
        h_avi.writeVideo(getframe(gcf));
    catch
        % Fallback deprecated avifile based video creation
        h_avi = addframe(h_avi, getframe(gcf));
    end
end

for i=1:len_w
    imagesc(img_morphed_3{i});
    axis image; axis off;drawnow;
    try
        % VideoWriter based video creation
        h_avi.writeVideo(getframe(gcf));
    catch
        % Fallback deprecated avifile based video creation
        h_avi = addframe(h_avi, getframe(gcf));
    end
end

disp('Done.');

try
    % VideoWriter based video creation
    h_avi.close();
catch
    % Fallback deprecated avifile based video creation
    h_avi = close(h_avi);
end
clear h_avi;

end