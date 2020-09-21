function [best,FSE]=synthesize(filename,jobj,payload,ORIGINAL,QF)  %选择图片
addpath jpegread\;%
addpath utils\;
dct=jobj.coef_arrays{1};                           %存dct系数 
Q_table=jobj.quant_tables{1};              %对量化表进行赋值
J = imread(ORIGINAL);%读取原始jpeg图像
FSE = zeros(1,length(payload)+1);
best = zeros(4,length(payload));
%%%%%%%%%%%%%%%%%%不同嵌入容量下的值%%%%%%%%%%%%%%%%%%%%%%%
for k = 1:length(payload)
    %在当前QF下的JPEG图嵌入不同的信息量
messLen = payload(k);
embed_bit=round(rand(1,messLen));  %当前messlen下随机产生嵌入比特
%%%%%%%%%%%%%%%%%%%%%%%%%%%尝试选择嵌入系数%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PSNR=zeros(1,64);
INCRE=zeros(1,64);
Q_cost=costFun(Q_table);            %将量化表的每个因子返回到空域中看它对像素产生的影响  
bin63=get63bin(dct);          %按列抽出每个DCT块中ij位置的系数为一行，相同位置为一行形成矩阵
[outbin63,capacity63,unitdistortion63]=getuintcost63bin(bin63,Q_cost);
[unitdistortion63,sort_index]=sort(unitdistortion63);        %对失真进行排序，排序好的块系数在sort_index
max_psnr = 0;
for selnum=12:3:3*floor(length(sort_index)/3)                %%遍历所有selnum，根据psnr寻找最佳的块嵌入数量K
    sel_index=sort_index(1:selnum);
    M=matrix_index(sel_index);                 %产生标记矩阵M
    DCT=mark(M,dct);                          %没问题，产生选择系数后的DCT块%%%
%%%%%%%%%%%%%%模拟修改图片产生嵌入序列%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
simulate_dct=simulate(DCT);         %模拟修改后的图片存贮在simulate_dct
counter_1=countDCT(DCT,1);
counter_0=countDCT(DCT,0);
[counter_0,sort_0]=sort(counter_0);        
table=jobj.quant_tables{1};
[order,vd_distor]=select_block2(simulate_dct,DCT,table,counter_1);   %根据模拟修改的方案贪心算法（失真大小）产生一个嵌入图片的序列,产生码流失真序列
%%%%%%%%%%%%%%%%%%%%%%%%按照嵌入序列，将信息嵌入图片%%%%%%%%%%%%%%%%%%%%%%
for r=1:length(order)                                    %寻找嵌入临界值
     if (sum(counter_1(order(1:r)))>=messLen)            %按每个块中1的数目
         order=order(1:r);
         sort_0=sort_0(1:r);        
         break;
     end
end
[stego1_dct,tag]=generate_stego(order,DCT,embed_bit,messLen);       %产生嵌入的DCT系数
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
 ssim_goad = SSIM(II,J);
 fid=fopen('stego.jpg','rb');
 bit1=fread(fid,'ubit1');
 fclose(fid);
 fid=fopen(ORIGINAL,'rb');
 bit2=fread(fid,'ubit1');
 fclose(fid);
 incre_bit=(length(bit1)-length(bit2));
 if max_psnr < psnr_goad
     max_psnr = psnr_goad;
     ssim_hou = ssim_goad;
     jobjj = jobj;
 end
    %%
    PSNR(selnum)=psnr_goad;
    INCRE(selnum)=incre_bit;
end
[best_psnr,index]=max(PSNR);                            %找到最好的psnr
best_incre=INCRE(index)/length(bit2)*100;                               %找到最好的incre_bit
filenamestego = strcat(filename,'_',num2str(messLen));
STEGO=['Stego_g512\QF' num2str(QF) '\',filenamestego,'.jpg'];
jpeg_write(jobjj,STEGO);
best(:,k)=[messLen,best_psnr,ssim_hou,best_incre];
FSE(k) = INCRE(index);
end
 FSE(k+1) = length(bit2);%最后一个存放原始文件大小
end