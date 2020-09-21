function bin63=get63bin(DCT)
[m,n]=size(DCT);
id=0;
bin63=zeros(63,m*n/64);
for i=1:8
    for j=1:8
        if ((i+j)~=2)
            pos=zeros(8,8);
            pos(i,j)=1;
            pos=logical(pos);
            pos=repmat(pos,m/8,n/8);     %把A矩阵复制吗m/8×n/8块
            temp=DCT(pos);               %把每一个dct块中第ij个位置的DCT系数抽出来形成向量
            id=id+1;
            bin63(id,:)=temp(:);  
            
        end
    end
end

end
