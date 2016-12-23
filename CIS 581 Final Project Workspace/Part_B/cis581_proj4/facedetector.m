function [ bbox ] = facedetector( I )
%FACEDETECOTR Summary of this function goes here
%   Detailed explanation goes here
    faceDetector = vision.CascadeObjectDetector;
    bbox = step(faceDetector,I);
    %{
    for i=1:4
        bbox(5,i) = 0;
    end
    %}
    % return bbox;
    shapeInserter = vision.ShapeInserter('BorderColor','Custom','CustomBorderColor',[255 255 255]);
    I_faces = step(shapeInserter, I, int32(bbox));
   %  figure; imshow(I_faces);
    
    MouthDetect = vision.CascadeObjectDetector('Mouth','MergeThreshold',16);
    BB=step(MouthDetect,I);

    
    EyeDetect = vision.CascadeObjectDetector('LeftEye');
    BB2=step(EyeDetect,I);
end

