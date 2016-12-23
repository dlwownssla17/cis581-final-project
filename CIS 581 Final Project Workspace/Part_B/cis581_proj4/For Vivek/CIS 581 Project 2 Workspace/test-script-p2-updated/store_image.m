img = (imread('project2_testimg.png'));
imgs = {};

max_size = [0,0,0];
for i=1:0.1:2
    % resize image
    tmp = imresize(img,i);
    
    % compute max size
    imgs = [imgs, tmp];
    max_size = max([max_size;size(tmp)]);
end

for i=1:11
    % compute padding size
    current_size = size(imgs{i});
    padsize = max_size-current_size(1:2);
    
    % padding accounding to the max size
    imgs{i} = padarray(imgs{i}, padsize, 'post'); % try 'both' and 'pre'
end

% render video
fname = 'test.avi';
try
    % VideoWriter based video creation
    h_avi = VideoWriter(fname, 'Uncompressed AVI');
    h_avi.FrameRate = 10;
    h_avi.open();
catch
    % Fallback deprecated avifile based video creation
    h_avi = avifile(fname,'fps',10);
end

for i=1:11
    imagesc(imgs{i});
    axis image; axis off;drawnow;
    try
        % VideoWriter based video creation
        h_avi.writeVideo(imgs{i});
    catch
        % Fallback deprecated avifile based video creation
        h_avi = addframe(h_avi, imgs{i});
    end
end
try
    % VideoWriter based video creation
    h_avi.close();
catch
    % Fallback deprecated avifile based video creation
    h_avi = close(h_avi);
end
clear h_avi;