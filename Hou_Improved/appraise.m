function [ PSNR ] = appraise(img1,img2)
%计算图像的峰值信噪比
img1=double(img1);
img2=double(img2);
L=length(img1(:));
mse = sum((img1(:)-img2(:)).^2)/L;

PSNR=10*log10(255*255/mse);

end

