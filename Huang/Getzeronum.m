function [zeronum]=Getzeronum(Blockdct)
[M,N] = size(Blockdct);
zeronum=zeros(M*N,3);
count=1;
for r=1:M
    for c=1:N
        zeronum(count,1)=r;
        zeronum(count,2)=c;
        zeronum(count,3)=sum(Blockdct{r,c}(:)==0);
        count=count+1;
    end
end
zeronum=sortrows(zeronum,-3);
end