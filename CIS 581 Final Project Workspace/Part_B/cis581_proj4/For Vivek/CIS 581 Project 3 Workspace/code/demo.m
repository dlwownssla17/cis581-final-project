clear;
I1 = imread('1.jpg');
I2 = imread('2.jpg');
img_input = {I1, I2};
img_mosaic = mymosaic(img_input);
imshow(img_mosaic);