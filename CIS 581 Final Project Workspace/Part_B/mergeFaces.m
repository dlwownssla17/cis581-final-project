function [ output_args ] = mergeFaces( replacementFileName, videoFiles )
    addpath('facepp-matlab-sdk-master');
    addpath('proj2');
    addpath('proj4a_blending');
    addpath('Proj4_Test/easy');
    addpath('Proj4_Test/medium');
    addpath('Proj4_Test/hard');
%MERGEFACES Summary of this function goes here
%   Detailed explanation goes here
    readers = cell(length(videoFiles),1);
    writers = cell(length(videoFiles),1);
    selectedFaces = cell(length(videoFiles),1);
    previousAllFaces = cell(length(videoFiles),1);
    previousFaceIndex = cell(length(videoFiles),1);
    ct = 1;
    for i=1:length(videoFiles)
        video = char(videoFiles(i));
        readers{i} = VideoReader(video);
        if i == 1
            while exist(strcat(video(1:end-4),'_morphed', int2str(ct), '.avi'), 'file') == 2
                ct = ct + 1;
            end
        end
        writers{i} = VideoWriter(strcat(video(1:end-4),'_morphed', int2str(ct), '.avi'),'Uncompressed AVI');
        open(writers{i});
    end
    
    mainCt = 1;
    
    scaleFactor = .5;
    while mainCt <= 100    
        % Run on all test videos in parallel
        for i=1:length(videoFiles)
            try
                reader = readers{i};
                writer = writers{i};
                
                if ~hasFrame(reader)
                    close(writer);
                    continue;
                end
                
                replacement = uint8(imresize(uint8(imread(replacementFileName)), .5));
                imwrite(replacement, 'replacement.jpg');

                target = uint8(imresize(uint8(readFrame(reader)), scaleFactor));
                imwrite(target, 'test.jpg');

                [ rst1, w1, h1, facePts1, face1 ] = callFaceApi('replacement.jpg', false, [], []);
                useReplacementFace = false;
                replacementFace = [];
                prevFaces = [];
                prevIndex = 0;
                if (mainCt ~= 1)
                    useReplacementFace = true;
                    replacementFace = selectedFaces{i};
                    prevFaces = previousAllFaces{i};
                    prevIndex = previousFaceIndex{i};
                end
                [ rst2, w2, h2, facePts2, face2, success2, allFaces2, faceIndex2 ] = callFaceApi('test.jpg', useReplacementFace, replacementFace, prevFaces, prevIndex);
                if ~success2
                    disp(strcat('Error in mainCt = ', int2str(mainCt), ', i = ', int2str(i)));
                    continue;
                end
                
                % Find top left corner of both faces
                topLeft1 = [(face1.position.center.x - (face1.position.width/2)) (face1.position.center.y - (face1.position.height/2))];
                topLeft2 = [(face2.position.center.x - (face2.position.width/2)) (face2.position.center.y - (face2.position.height/2))];
                topLeft1(1) = topLeft1(1) * w1 / 100;
                topLeft1(2) = topLeft1(2) * h1 / 100;
                topLeft2(1) = topLeft2(1) * w2 / 100;
                topLeft2(2) = topLeft2(2) * h2 / 100;
                topLeft1 = round(topLeft1);
                topLeft2 = round(topLeft2);

                % Extract images of just the faces from both images. This
                % will make blending look better.
                faceImg1 = toFaceImg(replacement, topLeft1,  ceil(face1.position.width * w1 / 100),  ceil(face1.position.height * h1 / 100));
                faceImg2 = toFaceImg(target, topLeft2,  floor(face2.position.width * w2 / 100),  floor(face2.position.height * h2 / 100));

                fp1 = face1.position;
                fp2 = face2.position;
                morphPts1 = [fp1.center.x, fp1.center.y;
                             fp1.eye_left.x, fp1.eye_left.y;
                             fp1.eye_right.x, fp1.eye_right.y;
                             fp1.mouth_left.x, fp1.mouth_left.y;
                             fp1.mouth_right.x, fp1.mouth_right.y;
                             fp1.nose.x, fp1.nose.y];
                morphPts2 = [fp2.center.x, fp2.center.y;
                             fp2.eye_left.x, fp2.eye_left.y;
                             fp2.eye_right.x, fp2.eye_right.y;
                             fp2.mouth_left.x, fp2.mouth_left.y;
                             fp2.mouth_right.x, fp2.mouth_right.y;
                             fp2.nose.x, fp2.nose.y];
                morphPts1(:,1) = morphPts1(:,1) .* w1 / 100 - topLeft1(1) + 1;
                morphPts1(:,2) = morphPts1(:,2) .* h1 / 100 - topLeft1(2) + 1;
                morphPts2(:,1) = morphPts2(:,1) .* w2 / 100 - topLeft2(1) + 1;
                morphPts2(:,2) = morphPts2(:,2) .* h2 / 100 - topLeft2(2) + 1;
                % Morph face images
                morph = morph_tps_wrapper(faceImg1, faceImg2, morphPts1, morphPts2, .5, .5);
                
                % If face can't be detected from .5 morph, try .4/.6 to see
                % if that works
                imwrite(morph{1}, 'morph.jpg');
                [ rst, w, h, facePts, morphFace, success ] = callFaceApi('morph.jpg', false, []);
                if (~success)
                    morph = morph_tps_wrapper(faceImg1, faceImg2, morphPts1, morphPts2, .4,.4);
                    imwrite(morph{1}, 'morph.jpg');
                    [ rst, w, h, facePts, morphFace, success ] = callFaceApi('morph.jpg', false, []);
                    if (~success)
                        morph = morph_tps_wrapper(faceImg1, faceImg2, morphPts1, morphPts2, .6,.6);
                        imwrite(morph{1}, 'morph.jpg');
                        [ rst, w, h, facePts, morphFace, success ] = callFaceApi('morph.jpg', false, []);
                        if (~success)
                            disp(strcat('Failure on: mainCt =', int2str(mainCt), ', i = ', int2str(i)));
                            continue;
                        end
                    end
                end

                % Get all landmarks so that convex hull can be computed
                landmark_names = fieldnames(facePts);
                allFacePts = zeros(length(landmark_names), 2);
                ct = 1;
                for j = 1 : length(landmark_names)
                    pts1 = getfield(facePts, landmark_names{j});
                    allFacePts(ct,1) = pts1.x * w / 100;
                    allFacePts(ct,2) = pts1.y * h / 100;
                    ct = ct + 1;
                end
                
                % Extract all points in the morphed image within the convex
                % hull of the face and blend that to the target image.
                x = allFacePts(:,1);
                y = allFacePts(:,2);
                K = convhull(allFacePts(:,1),allFacePts(:,2));
                [r, c, ~] = size(morph{1});
                [Xq, Yq] = meshgrid(1:c, 1:r);
                mask_inpolygon = inpolygon(Xq(:), Yq(:), x(K), y(K)) ~= 0;
                mask = reshape(mask_inpolygon, [r, c])';           
                resultImg = seamlessCloningPoisson(morph{1}, target, mask, topLeft2(1), topLeft2(2));
                if mod(mainCt,10) == 0
                    figure; imshow(resultImg);
                end
                % Write new frame to video
                writeVideo(writer, resultImg);
                disp('COMPLETE');
                selectedFaces{i} = face2;
                previousAllFaces{i} = allFaces2;
                previousFaceIndex{i} = faceIndex2;
            catch
                disp(strcat('Error in mainCt = ', int2str(mainCt), ', i = ', int2str(i)));
                continue;
            end
        end
        mainCt = mainCt + 1;
    end
end

function [pts1, pts2] = addCtrlPoint(pt1, pt2, pts1, pts2, w1, h1, w2, h2, topLeft1, topLeft2)
    ct = size(pts1, 1)+1;
    pts1(ct,1) = pt1.x * w1 / 100 - topLeft1(1) + 1;
    pts1(ct,2) = pt1.y * h1 / 100 - topLeft1(2) + 1;
    pts2(ct,1) = pt2.x * w2 / 100 - topLeft2(1) + 1;
    pts2(ct,2) = pt2.y * h2 / 100 - topLeft2(2) + 1;
end

function [newImg] = toFaceImg(img, topLeft, w, h)
    newImg = uint8(img(topLeft(2) - 1 + (1:h), topLeft(1) - 1 + (1:w), :));
end

