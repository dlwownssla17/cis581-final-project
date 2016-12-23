function [ output_args ] = mergeFaces( videoFiles )
    addpath('facepp-matlab-sdk-master');
    addpath('proj2');
    addpath('proj4a_blending');
    addpath('Proj4_Test/easy');
    addpath('Proj4_Test/medium');
    addpath('Proj4_Test/hard');
%MERGEFACES Summary of this function goes here
%   Detailed explanation goes here
    readers = cell(size(videoFiles));
    writers = cell(size(videoFiles));
    for i=1:length(videoFiles)
        video = char(videoFiles(i));
        readers{i} = VideoReader(video);
        disp(strcat(video(1:end-4),'_morphed1.avi'));
        writers{i} = VideoWriter(strcat(video(1:end-4),'_morphed1.avi'),'Uncompressed AVI');
        open(writers{i});
    end
    
    ct = 1;
    
    scaleFactor = .5;
    while ct <= 100    
        for i=1:length(videoFiles)
            try
                reader = readers{i};
                writer = writers{i};
                if ~hasFrame(reader)
                    close(writer);
                    continue;
                end
                replacementFileName = 'trump.jpg';        
                replacement = uint8(imresize(uint8(imread(replacementFileName)), .5));

                imwrite(replacement, 'replacement.jpg');

                target = uint8(imresize(uint8(readFrame(reader)), scaleFactor));
                imwrite(target, 'test.jpg');

                [ rst1, w1, h1, facePts1, face1 ] = callFaceApi('replacement.jpg');
                [ rst2, w2, h2, facePts2, face2 ] = callFaceApi('test.jpg');

                topLeft1 = [(face1.position.center.x - (face1.position.width/2)) (face1.position.center.y - (face1.position.height/2))];
                topLeft2 = [(face2.position.center.x - (face2.position.width/2)) (face2.position.center.y - (face2.position.height/2))];
                topLeft1(1) = topLeft1(1) * w1 / 100;
                topLeft1(2) = topLeft1(2) * h1 / 100;
                topLeft2(1) = topLeft2(1) * w2 / 100;
                topLeft2(2) = topLeft2(2) * h2 / 100;
                topLeft1 = round(topLeft1);
                topLeft2 = round(topLeft2);


                faceImg1 = toFaceImg(replacement, topLeft1,  ceil(face1.position.width * w1 / 100),  ceil(face1.position.height * h1 / 100));
                faceImg2 = toFaceImg(target, topLeft2,  floor(face2.position.width * w2 / 100),  floor(face2.position.height * h2 / 100));

                morphPts1 = [];
                morphPts2 = [];

                % center
                [morphPts1, morphPts2] = addCtrlPoint(face1.position.center, face2.position.center, morphPts1, morphPts2, w1, h1, w2, h2, topLeft1, topLeft2);

                % eye_left
                [morphPts1, morphPts2] = addCtrlPoint(face1.position.eye_left, face2.position.eye_left, morphPts1, morphPts2, w1, h1, w2, h2, topLeft1, topLeft2);


                % eye_right
                [morphPts1, morphPts2] = addCtrlPoint(face1.position.eye_right, face2.position.eye_right, morphPts1, morphPts2, w1, h1, w2, h2, topLeft1, topLeft2);


                % mouth_left
                [morphPts1, morphPts2] = addCtrlPoint(face1.position.mouth_left, face2.position.mouth_left, morphPts1, morphPts2, w1, h1, w2, h2, topLeft1, topLeft2);


                % mouth_right
                [morphPts1, morphPts2] = addCtrlPoint(face1.position.mouth_right, face2.position.mouth_right, morphPts1, morphPts2, w1, h1, w2, h2, topLeft1, topLeft2);


                % nose
                [morphPts1, morphPts2] = addCtrlPoint(face1.position.nose, face2.position.nose, morphPts1, morphPts2, w1, h1, w2, h2, topLeft1, topLeft2);


                w=0:0.1:1;
                morph = morph_tps_wrapper(faceImg1, faceImg2, morphPts1, morphPts2, .5, .5);

                imwrite(morph{1}, 'morph.jpg');
                [ rst, w, h, facePts, morphFace ] = callFaceApi('morph.jpg');

                landmark_names = fieldnames(facePts);
                allFacePts = zeros(length(landmark_names), 2);
                ct = 1;
                for j = 1 : length(landmark_names)
                    pts1 = getfield(facePts, landmark_names{j});
                    allFacePts(ct,1) = pts1.x * w / 100;
                    allFacePts(ct,2) = pts1.y * h / 100;
                    ct = ct + 1;
                end

                x = allFacePts(:,1) + topLeft2(2) - 1;
                y = allFacePts(:,2) + topLeft2(1) - 1;
                K = convhull(allFacePts(:,1),allFacePts(:,2));
                img = target;
                mask = zeros(size(img,1), size(img,2));
                for j=1:size(morph{1},1)
                    for k=1:size(morph{1},2)
                        if inpolygon(k+topLeft2(2)-1, j+topLeft2(1)-1, x(K), y(K))
                            for l=1:3
                                img(k+topLeft2(2)-1, j+topLeft2(1)-1, l) = morph{1}(k,j,l);
                            end
                        end
                        mask(k+topLeft2(2)-1, j+topLeft2(1)-1) = 1;
                    end
                end
                resultImg = seamlessCloningPoisson(img, target, mask, 0, 0);
                writeVideo(writer, resultImg);
            catch
                continue;
            end
        end
        ct = ct + 1;
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
    % img = uint8(img);
    newImg = zeros(w,h,3);
    for i=1:w
        for j=1:h
            for k=1:3
                %disp(strcat(num2str(i), ',', num2str(j), ',', num2str(i + topLeft(1) - 1), ',', num2str(j + topLeft(2) - 1), ','));
                %disp(size(img));
                newImg(j,i,k) = img(j + topLeft(2) - 1, i + topLeft(1) - 1, k);
            end
        end
    end
    newImg = uint8(newImg);
end

