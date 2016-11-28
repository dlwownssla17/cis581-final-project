I = imread('ocean.jpg');

[IcxDraw, TxDraw] = carvDrawOne(I, false, true);
figure; imshow(IcxDraw);
imwrite(IcxDraw, 'ocean_ver_seam_drawn.jpg');
[Icx, Tx] = carv(I, 0, 1);
figure; imshow(Icx);
imwrite(Icx, 'ocean_ver_seam_removed.jpg');
[Icx38, Tx38] = carv(I, 0, 38);
figure; imshow(Icx38);
imwrite(Icx38, 'ocean_ver_seam_removed_38.jpg');

[IcyDraw, TyDraw] = carvDrawOne(I, true, false);
figure; imshow(IcyDraw);
imwrite(IcyDraw, 'ocean_hor_seam_drawn.jpg');
[Icy, Ty] = carv(I, 1, 0);
figure; imshow(Icy);
imwrite(Icy, 'ocean_hor_seam_removed.jpg');
[Icy48, Ty48] = carv(I, 48, 0);
figure; imshow(Icy48);
imwrite(Icy48, 'ocean_hor_seam_removed_48.jpg');

[Ic1x1, T1x1] = carv(I, 1, 1);
figure; imshow(Ic1x1);
imwrite(Ic1x1, 'ocean_1x1_removed.jpg');
[Ic48x38, T48x38] = carv(I, 48, 38);
figure; imshow(Ic48x38);
imwrite(Ic48x38, 'ocean_48x38_removed.jpg');