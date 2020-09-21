function Q_cost=costFun(Q)
[m,n]=size(Q);
Q_cost=zeros(m,n,63);
id=0;
for i=1:8
    for j=1:8
            if (i+j)~=2
            Diff=zeros(8,8);
            Diff(i,j)=1;
            temp=IDCT(Q.*Diff);
             id=id+1;
             Q_cost(:,:,id)=temp;%sqrt(temp/64);
            end
    end
end

end