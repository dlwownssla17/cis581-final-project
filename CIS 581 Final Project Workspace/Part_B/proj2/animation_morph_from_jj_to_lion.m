function[] = animation_morph_from_jj_to_lion(do_trig)
load('im_vals.mat');
img_jj = imread(im1);
img_lion = imread(im2);

h = figure(2); clf;
whitebg(h,[0 0 0]);

if do_trig
    fname = 'Project2_eval_jj_to_lion_trig.avi';
else
    fname = 'Project2_eval_jj_to_lion_tps_full_cycle.avi';
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

w = 0:(1/120):1;
if (do_trig)
    img_morphed = morph(img_jj, img_lion, im1_pts, im2_pts, w, w);
else
    img_morphed = morph_tps_wrapper(img_jj, img_lion, im1_pts, im2_pts, w, w);
end

% morph in reverse direction (commented out)

% w = 1:(-1/60):0;
% if (do_trig)
%     img_morphed_rev = morph(img_jj, img_lion, im1_pts, im2_pts, w, w);
% else
%     img_morphed_rev = morph_tps_wrapper(img_jj, img_lion, im1_pts, im2_pts, w, w);
% end

disp('Completed generating morphed images.');
disp('Adding frames...');

for i=1:61
    imagesc(img_morphed{i});
    axis image; axis off;drawnow;
    try
        % VideoWriter based video creation
        h_avi.writeVideo(getframe(gcf));
    catch
        % Fallback deprecated avifile based video creation
        h_avi = addframe(h_avi, getframe(gcf));
    end
end

% add frames for reverse (commented out)

% for i=1:61
%     imagesc(img_morphed_rev{i});
%     axis image; axis off;drawnow;
%     try
%         % VideoWriter based video creation
%         h_avi.writeVideo(getframe(gcf));
%     catch
%         % Fallback deprecated avifile based video creation
%         h_avi = addframe(h_avi, getframe(gcf));
%     end
% end

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