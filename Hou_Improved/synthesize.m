function [best,FSE]=synthesize(filename,jobj,payload,ORIGINAL,QF)  %选择图片
addpath jpegread\;
dct=jobj.coef_arrays{1};                           %存dct系数 
Q_table=jobj.quant_tables{1};              %对量化表进行赋值
J = imread(ORIGINAL);%读取原始jpeg图像
FSE = zeros(1,length(payload)+1);
best = zeros(4,length(payload));
%%%%%%%%%%%%%%%%%%不同嵌入容量下的值%%%%%%%%%%%%%%%%%%%%%%%
for k = 1:1
%在当前QF下的JPEG图嵌入不同的信息量
carry = payload(k);
embed_bit=round(rand(1,carry));  %当前messlen下随机产生嵌入比特
%%%%%%%%%%%%%%%%%%%%%%%%%%%尝试选择嵌入系数%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PSNR=zeros(1,64);
INCRE=zeros(1,64);
Q_cost=costFun(Q_table);            %将量化表的每个因子返回到空域中看它对像素产生的影响  
bin63=get63bin(dct);          %按列抽出每个DCT块中ij位置的系数为一行，相同位置为一行形成矩阵
[outbin63,capacity63,unitdistortion63]=getuintcost63bin(bin63,Q_cost);
[unitdistortion63,sort_index]=sort(unitdistortion63);        %对失真进行排序，排序好的块系数在sort_index
for selnum=12:3:3*floor(length(sort_index)/3)                %%遍历所有selnum，根据psnr寻找最佳的块嵌入数量K
    sel_index=sort_index(1:selnum);
    M=matrix_index(sel_index);                 %产生标记矩阵M
    DCT=mark(M,dct);                          %没问题，产生选择系数后的DCT块%%%
sum_R = sum_payload(DCT);
if sum_R < carry
    continue;
end
    %%%%%%%%%%%%%%模拟修改图片产生嵌入序列%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
simulate_dct=simulate(DCT);         %模拟修改后的图片存贮在simulate_dct
counter_1=countDCT(DCT,1);
counter_0=countDCT(DCT,0);
[counter_0,sort_0]=sort(counter_0);        
table=jobj.quant_tables{1};
[order,vd_distor]=select_block2(simulate_dct,DCT,table,counter_1);   %根据模拟修改的方案贪心算法（失真大小）产生一个嵌入图片的序列,产生码流失真序列
%%%%%%%%%%%%%%%%%%%%%%%%按照嵌入序列，将信息嵌入图片%%%%%%%%%%%%%%%%%%%%%%
for r=1:length(order)                                    %寻找嵌入临界值
     if (sum(counter_1(order(1:r)))>=carry)            %按每个块中1的数目
         order=order(1:r);
         sort_0=sort_0(1:r);        
         break;
     end
end
[stego1_dct,tag]=generate_stego(order,DCT,embed_bit,carry);       %产生嵌入的DCT系数
if tag==1
 continue;
end
stego_dct=recoverstego(dct,stego1_dct,sel_index);         %恢复其他系数
%%%%%%%%%%%%%%%%%%%%%%%%%%用上面产生的stego.dct产生嵌入图片%%%%%%%%%%%%%%%%%%%%%%%
jobj.coef_arrays{1} = stego_dct;
jpeg_write(jobj,'stego.jpg');
 %% %%%&%%%%%%%%%%%%%%%%%%%%%%%%%计算失真和码流扩张%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 II=imread('stego.jpg');
 psnr_goad=appraise(II,J);
 fid=fopen('stego.jpg','rb');
 bit1=fread(fid,'ubit1');
 fclose(fid);
 fid=fopen(ORIGINAL,'rb');
 bit2=fread(fid,'ubit1');
 fclose(fid);
 incre_bit=length(bit1)-length(bit2);
 
 %%
 PSNR(selnum)=psnr_goad;
 INCRE(selnum)=incre_bit;
end %找到最优K

[best_psnr,index]=max(PSNR);                            %找到最好的psnr
%% 上述步骤已找到最优K
sel_index=sort_index(1:index);
M=matrix_index(sel_index);                 %产生标记矩阵M
DCT=mark(M,dct);                          %此时频率位置确定之后的DCT块为载体信号%%%

    %%%%%%%%%%%%%%模拟修改图片产生嵌入序列%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
simulate_dct=simulate(DCT);         %模拟修改后的图片存贮在simulate_dct    
[M,N] = size(DCT);
ori_Blockdct = mat2cell(DCT,8 * ones(1,M/8),8 * ones(1,N/8));%把原来的图像矩阵分割成N个8*8的Block
simulate_Blockdct = mat2cell(simulate_dct,8 * ones(1,M/8),8 * ones(1,N/8));%把模拟嵌入的图像矩阵分割成N个8*8的Block
dct_block = mat2cell(dct,8 * ones(1,M/8),8 * ones(1,N/8));
[ simulate_Blockdct ] = stego( simulate_Blockdct,dct_block,sel_index ); %恢复其他系数

[add,psnring]=get_psnring(simulate_Blockdct,dct_block,jobj);   %获取嵌入代价
R=getpayload(ori_Blockdct);
[M,N] = size(ori_Blockdct);
%%
E1=reshape(add,M*N,1);
D1=reshape(psnring,M*N,1);
E = E1'; %转置为一行。
E = mapminmax(E, 0, 1); % 归一化。
E = reshape(E, size(E1)); %
D = D1'; %转置为一行。
D = mapminmax(D, 0, 1); % 归一化。
D = reshape(D, size(D1)); %
R=reshape(R,M*N,1);
C=carry;

[x1,g1] = intlinprog(E',1:M*N,-R',-C,[],[],zeros(M*N,1),ones(M*N,1));%求出最优FSE
disp('单目标');
A = [-R';E'];
alpha = 1;  %权重值
g = g1 + abs(alpha*g1);
b = [-C;g];
x=intlinprog(D',1:M*N,A,b,[],[],zeros(M*N,1),ones(M*N,1)); %单目标计算块决策变量，在满足FSE时的最优PSNR对应的决策变量
%x为选中哪些块能满足条件
x=uint8(reshape(x,M,N));
%%%%%%%%%%%%%%%%%%%%%%%%按照嵌入序列，将信息嵌入图片%%%%%%%%%%%%%%%%%%%%%%
[stego1_dct]=jpeg_emdding(embed_bit,ori_Blockdct,x);       %产生嵌入的DCT系数
[M,N] = size(dct);
dct_block = mat2cell(dct,8 * ones(1,M/8),8 * ones(1,N/8));
[ stego_dct ] = stego( stego1_dct,dct_block,sel_index ); %恢复其他系数
%%%%%%%%%%%%%%%%%%%%%%%%%%用上面产生的stego.dct产生嵌入图片%%%%%%%%%%%%%%%%%%%%%%%
jobj.coef_arrays{1} = cell2mat(stego_dct);      
filenamestego = strcat(filename,'_',num2str(carry));
STEGO=['Stego\QF' num2str(QF) '\',filenamestego,'.jpg'];
jpeg_write(jobj,STEGO);
 %% %%%&%%%%%%%%%%%%%%%%%%%%%%%%%计算失真和码流扩张%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 II=imread(STEGO);
 psnr_goad=appraise(II,J);
 ssim_goad = SSIM(II,J);
 fid=fopen(STEGO,'rb');
 bit1=fread(fid,'ubit1');
 fclose(fid);
 fid=fopen(ORIGINAL,'rb');
 bit2=fread(fid,'ubit1');
 fclose(fid);
 ZZ = (length(bit1)-length(bit2));
 incre_bit=ZZ/length(bit2)*100;
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 best(:,k)=[carry,psnr_goad,ssim_goad,incre_bit];
 FSE(k) = ZZ;
end                %%%所有payload嵌入完成
 FSE(k+1) = length(bit2);%最后一个存放原始文件大小