function [ rst, img_width, img_height, landmark_points, bestFace, success ] = callFaceApi( img, useReplacementFace, replacementFace )
    addpath('facepp-matlab-sdk-master');
%GETLANDMARKPTS Summary of this function goes here
%   Detailed explanation goes here
    
    fileID = fopen('keys.txt','r');
    API_KEY = fgetl(fileID);
    API_SECRET = fgetl(fileID);
    fclose(fileID);
    
     % If you have chosen Amazon as your API sever and 
    % changed API_KEY&API_SECRET into yours, 
    % pls reform the FACEPP call as following :
    % api = facepp(API_KEY, API_SECRET, 'US')
    api = facepp(API_KEY, API_SECRET, 'US');

    % Detect faces in the image, obtain related information (faces, img_id, img_height, 
    % img_width, session_id, url, attributes)
    rst = detect_file(api, img, 'all');
    img_width = rst{1}.img_width;
    img_height = rst{1}.img_height;
    face = rst{1}.face;
    fprintf('Totally %d faces detected!\n', length(face));
    
    %{
    im = imread(img);
    figure; imshow(im);
    hold on;
    %}
    if isempty(face)
        success = false;
        rst = []; 
        img_width = 0; 
        img_height = 0; 
        landmark_points = [];
        bestFace = [];
        return;
    end
        
    faceIndex = 1;
    
    if (useReplacementFace)
        maxScore = 0;
        for i=1:length(face)
            score = compare(api, face{i}.face_id, replacementFace.face_id);
            if score{1}.similarity > maxScore
                maxScore = score{1}.similarity;
                faceIndex = i;
            end
        end
    else
        maxArea = 0;
        for i=1:length(face)
            area = face{i}.position.width * face{i}.position.height;
            if area > maxArea 
                maxArea = area;
                faceIndex = i;
            end
        end
    end

    bestFace = face{faceIndex};

    % Draw face rectangle on the image
    face_i = face{faceIndex};
    center = face_i.position.center;
    w = face_i.position.width / 100 * img_width;
    h = face_i.position.height / 100 * img_height;
    
    %{
    rectangle('Position', ...
        [center.x * img_width / 100 -  w/2, center.y * img_height / 100 - h/2, w, h], ...
        'Curvature', 0.4, 'LineWidth',2, 'EdgeColor', 'blue');
    %}
    % Detect facial key points
    rst2 = api.landmark(face_i.face_id, '83p');
    landmark_points = rst2{1}.result{1}.landmark;
    success = true;
end

