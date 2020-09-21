function [ I_stego ] = stego( S_stego,oriBlockdct,sel_index )
%STEGO 此处显示有关此函数的摘要
%   此处显示详细说明
I_stego = oriBlockdct;
[m,n] = size(oriBlockdct);
for i = 1:m
    for j = 1:n
        S_stego{i,j} = S_stego{i,j}';
        I_stego{i,j} = I_stego{i,j}';
        I_stego{i,j}(sel_index(:)+1) = S_stego{i,j}(sel_index(:)+1);
        I_stego{i,j} = I_stego{i,j}';
    end
end


end

