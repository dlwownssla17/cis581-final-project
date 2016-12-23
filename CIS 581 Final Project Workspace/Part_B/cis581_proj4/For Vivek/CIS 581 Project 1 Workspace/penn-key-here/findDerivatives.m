function [J, theta, Jx, Jy] = findDerivatives(I, Gx, Gy)
dx = [1,-1];
dy = dx';
G_ = conv2(Gx,Gy,'full');
dx = conv2(G_,dx,'full');
dy = conv2(G_,dy,'full');
I = im2double(I);
Jx = conv2(I,dx,'same');
Jy = conv2(I,dy,'same');
theta = atan2(Jy,Jx);
J = sqrt(Jx .* Jx + Jy .* Jy);
end