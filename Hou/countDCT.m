function [ counter ] = count( dct,x )
%计算每个8×8块的嵌入容量
[m,n]=size(dct);
m=m/8;
n=n/8;
counter=zeros(1,m*n);  %计算当前块的嵌入容量
k=0;
for i=1:m
    for j=1:n
    temp=dct(8*(i-1)+1:8*i,8*(j-1)+1:8*j);
    k=k+1;
    counter(k)=length(find(abs(temp)==x));
    end
end
end

