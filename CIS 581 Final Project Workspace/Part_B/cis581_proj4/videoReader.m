function [ output_args ] = videoReader( video1, video2 )
%VIDEOREADER Summary of this function goes here
%   Detailed explanation goes here
    v1 = VideoReader(video1);
    v2 = VideoReader(video2);
    resize = .5;
    v = VideoWriter('newfile7.avi','Uncompressed AVI');
    open(v);
    
    ct = 0;
    
    while hasFrame(v1) && hasFrame(v2)
        try
            frame1 = imresize(uint8(readFrame(v1)), resize);
            tmp = frame1;

            frame2 = imresize(uint8(readFrame(v2)), resize);
            % mask = maskImage(frame1);
            bbox1 = facedetector(frame1);
            bbox2 = facedetector(frame2);
            
            % figure; imshow(frame2);
            
            % disp(bbox2);
            
           % for i=1:size(bbox1,1)
                currMax = bbox1(1,3);
                i1 = 1;
                for i=1:size(bbox1,1)
                    if currMax < bbox1(i,3)
                        i1 = i;
                        currMax = bbox1(i,3);
                    end
                end

                currMax = bbox2(1,3);
                i2 = 1;
                for i=1:size(bbox2,1)
                    if currMax < bbox2(i,3)
                        i2 = i;
                        currMax = bbox2(i,3);
                    end
                end

                face1 = zeros(-bbox1(i1,1)+bbox1(i1,3), -bbox1(i1,2)+bbox1(i1,4));
                mask = zeros(size(frame1,1), size(frame1,2), 3);
                for j=bbox1(i1,1):(bbox1(i1,1)+bbox1(i1,3)-1)
                    for k=bbox1(i1,2):(bbox1(i1,2)+bbox1(i1,4)-1)
                        mask(k,j) = frame1(k,j);
                        for l=1:3
                            face1(k-bbox1(i1,2)+1,j-bbox1(i1,1)+1,l) = frame1(k,j,l);
                        end
                    end
                end  

                face2 = zeros(-bbox2(i2,1)+bbox2(i2,3), -bbox2(i2,2)+bbox2(i2,4));
                for j=bbox2(i2,1):(bbox2(i2,1)+bbox2(i2,3)-1)
                    for k=bbox2(i2,2):(bbox2(i2,2)+bbox2(i2,4)-1)
                        for l=1:3
                            face2(k-bbox2(i2,2)+1,j-bbox2(i2,1)+1,l) = frame2(k,j,l);
                        end
                    end
                end 

                face1 = uint8(face1);
                face2 = uint8(face2);

                face1_pts = zeros(4,2);
                face2_pts = zeros(4,2);

                minX = 0;
                minY = 0;
                maxX = 0;
                maxY = 0;

                corners = zeros(4,2);

                EyeDetect = vision.CascadeObjectDetector('LeftEye');
                bbLeye1=step(EyeDetect,face1);
                index = 1;
                min = bbLeye1(1,1);
                for i=1:size(bbLeye1,1)
                    if bbLeye1(i,1) < min
                        min = bbLeye1(i,1);
                        index = i;
                    end
                end
                minX = bbLeye1(index,1);
                minY = bbLeye1(index,2);
                corners(1,1) = bbLeye1(index,1);
                corners(1,2) = bbLeye1(index,2);
                face1_pts(1,1) = bbLeye1(index,1) + (bbLeye1(index,3) / 2);
                face1_pts(1,2) = bbLeye1(index,2) + (bbLeye1(index,4) / 2);

                EyeDetect = vision.CascadeObjectDetector('LeftEye');
                bbLeye2=step(EyeDetect,face2);
                index = 1;
                min = bbLeye2(1,1);
                for i=1:size(bbLeye2,1)
                    if bbLeye2(i,1) < min
                        min = bbLeye2(i,1);
                        index = i;
                    end
                end
                face2_pts(1,1) = bbLeye2(index,1) + (bbLeye2(index,3) / 2);
                face2_pts(1,2) = bbLeye2(index,2) + (bbLeye2(index,4) / 2);

                EyeDetect = vision.CascadeObjectDetector('RightEye');
                bbLeye1=step(EyeDetect,face1);
                index = 1;  
                max = bbLeye1(1,1);  
                for i=1:size(bbLeye1,1)
                    if bbLeye1(i,1) > max
                        max = bbLeye1(i,1);
                        index = i;
                    end
                end
                corners(2,1) = bbLeye1(index,1)+bbLeye1(index,3);
                corners(2,2) = bbLeye1(index,2);

                maxX = bbLeye1(index,1) + bbLeye1(index,3);
                % minY = min(minY, bbLeye1(index,2));
                face1_pts(2,1) = bbLeye1(index,1) + (bbLeye1(index,3) / 2);
                face1_pts(2,2) = bbLeye1(index,2) + (bbLeye1(index,4) / 2);

                bbLeye2=step(EyeDetect,face2);
                index = 1;
                max = bbLeye2(1,1);
                for i=1:size(bbLeye2,1)
                    if bbLeye2(i,1) > max
                        max = bbLeye2(i,1);
                        index = i;
                    end
                end
                face2_pts(2,1) = bbLeye2(index,1) + (bbLeye2(index,3) / 2);
                face2_pts(2,2) = bbLeye2(index,2) + (bbLeye2(index,4) / 2);

                EyeDetect = vision.CascadeObjectDetector('Mouth');
                bbLeye1=step(EyeDetect,face1);
                index = 1;
                max = bbLeye1(1,2);
                for i=1:size(bbLeye1,1)
                    if bbLeye1(i,2) > max
                        max = bbLeye1(i,2);
                        index = i;
                    end
                end
                maxY = bbLeye1(index,2) + bbLeye1(index,4);
                corners(3,1) = bbLeye1(index,1)+bbLeye1(index,3);
                corners(3,2) = bbLeye1(index,2)+bbLeye1(index,4);
                face1_pts(3,1) = bbLeye1(index,1) + (bbLeye1(index,3) / 2);
                face1_pts(3,2) = bbLeye1(index,2) + (bbLeye1(index,4) / 2);

                
                bbLeye2=step(EyeDetect,face2);
                index = 1;
                max = bbLeye2(1,2);
                for i=1:size(bbLeye2,1)
                    if bbLeye2(i,2) > max
                        max = bbLeye2(i,2);
                        index = i;
                    end
                end
                face2_pts(3,1) = bbLeye2(index,1) + (bbLeye2(index,3) / 2);
                face2_pts(3,2) = bbLeye2(index,2) + (bbLeye2(index,4) / 2);

                EyeDetect = vision.CascadeObjectDetector('Nose');
                bbLeye1=step(EyeDetect,face1);
                face1_pts(4,1) = bbLeye1(1,1) + (bbLeye1(1,3) / 2);
                face1_pts(4,2) = bbLeye1(1,2) + (bbLeye1(1,4) / 2);
                corners(4,1) = bbLeye1(1,1) + (bbLeye1(1,3) / 2);
                corners(4,2) = bbLeye1(1,2) + (bbLeye1(1,4) / 2);

                bbLeye2=step(EyeDetect,face2);
                face2_pts(4,1) = bbLeye2(1,1) + (bbLeye2(1,3) / 2);
                face2_pts(4,2) = bbLeye2(1,2) + (bbLeye2(1,4) / 2);




                x = corners(:,1);
                y = corners(:,2);
                w = 0:0.1:1;
                morph_img = morph_tps_wrapper(face1, face2, face1_pts, face2_pts, .5, .5);
                K = convhull(corners(:,1), corners(:,2));


                resultImg = uint8(frame2);
                mask = zeros(size(frame2,1), size(frame2,2));
                % figure; imshow(resultImg); hold on;
                % plot(x(K)+bbox2(i2,1), y(K)+bbox2(i2,2), '*');
                for j=1:size(frame2,1)
                    for k=1:size(frame2,2)
                        if inpolygon(k,j,x(K)+bbox2(i2,1),y(K)+bbox2(i2,2))
                            if j-bbox2(i2,2)+1 <= 0 || j-bbox2(i2,2)+1 > size(morph_img{1},1) || k-bbox2(i2,1)+1 <= 0 || k-bbox2(i2,1)+1 > size(morph_img{1}, 2)
                                continue;
                            end
                            mask(j,k) = 1;
                            for l=1:3
                                resultImg(j,k,l) = morph_img{1}(j-bbox2(i2,2)+1,k-bbox2(i2,1)+1,l);
                            end
                        end                    
                    end
                end
                resultImg = seamlessCloningPoisson(resultImg, frame2, mask, 0,0);
                
                % figure; imshow(resultImg);

                writeVideo(v,resultImg);
                ct = ct + 1;
                if mod(ct,10) == 0
                    disp(ct);
                end
        catch ME
            disp('CAME HERE');
            % rethrow(ME);
            continue;
        end
    end
    close(v);
end

