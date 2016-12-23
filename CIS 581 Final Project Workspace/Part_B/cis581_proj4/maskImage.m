function mask = maskImage(Img)
imshow(Img);
mask = createMask(imfreehand);
end