sourceImg = imread('harambe.jpg');
targetImg = imread('rushmore.jpg');
mask = maskImage(sourceImg);
resultImg = seamlessCloningPoisson(sourceImg, targetImg, mask, 124, 51);
figure; imshow(resultImg);
imwrite(resultImg, 'harambeForPresident2.jpg');