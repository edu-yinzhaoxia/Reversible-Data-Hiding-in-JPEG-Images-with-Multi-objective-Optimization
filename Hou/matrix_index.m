function [ matrix ] = matrix_index(sel_index)
matrix=zeros(8);
for p=1:length(sel_index)
    row=ceil((sel_index(p)+1)/8);
    col=mod(sel_index(p),8)+1;
    matrix(row,col)=1;
end

end

