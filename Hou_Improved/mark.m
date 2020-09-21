function [ DCT ] = mark(M,dct)
%根据M标记每一个dct块，产生标记后的矩阵DCT
[m,n]=size(dct);
m=m/8;
n=n/8;
DCT=dct;
 for i=1:m
    for j=1:n
        temp_1=dct(8*(i-1)+1:8*i,8*(j-1)+1:8*j);     %选择8×8的dct块
         temp=M.*temp_1;                           %标记后的8×8块
        DCT(8*(i-1)+1:8*i,8*(j-1)+1:8*j)=temp;
    end
end

