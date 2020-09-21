clear
clc
addpath(genpath('JPEG_Toolbox'));
addpath(genpath('E:\MATLABR2016bworkspace\data set\g512\'));
filePath = 'E:\MATLABR2016bworkspace\data set\g512\';%图像路径
imgPathList = dir(strcat(filePath,'\*.pgm'));% 获取所有pgm图像
imgNum = length(imgPathList);% 获取pgm图像总量
dbstop if error
tic
for QF = 30:20:90
    %设置payload步长
if QF == 30
    payload = 2000:1000:9000;
elseif QF == 50
    payload = 2000:2000:14000;
elseif QF == 70
    payload = 2000:2000:18000;
elseif QF == 90
    payload = 2000:4000:30000;
end
result = cell(imgNum,1);
payload_length = length(payload);
psnr_sum = zeros(1,payload_length);  %所有图像某一QF下的PSNR总值
filesize_sum = zeros(1,payload_length); %所有图像某一QF下的FSE总值
ssim_sum = zeros(1,payload_length); %所有图像某一QF下的SSIM总值
sum_imgNum = imgNum;  %记录符合选定最大payload的图像的个数
for kkk = 1:imgNum
filename = imgPathList(kkk).name;
imwrite(uint8(imread(filename)),strcat('name',num2str(QF),'.jpg'),'jpg','quality',QF);      %在当前QF下压缩
filename1=strcat('name',num2str(QF),'.jpg');
%% 解析JPEG文件
ORIGINAL = filename1;
jpeg_info = jpeg_read(ORIGINAL);%解析JPEG图像
ori_jpeg = imread(ORIGINAL);%读取原始jpeg图像
quant_tables = jpeg_info.quant_tables{1,1};%获取量化表
dct_coef = jpeg_info.coef_arrays{1,1};%获取dct系数
S = getsignal(dct_coef);
R=getpayload_HS(S);
sum_R = sum(R(:));
%% 
if QF == 30 && sum_R < 9000
    sum_imgNum = sum_imgNum - 1;
    continue;
elseif QF == 50 && sum_R < 14000
    sum_imgNum = sum_imgNum - 1;
    continue;
elseif QF == 70 && sum_R < 18000
    sum_imgNum = sum_imgNum - 1;
    continue;
elseif QF == 90 && sum_R < 30000
    sum_imgNum = sum_imgNum - 1;
    continue;
end
[add,psnring]=getadd_psnr_HS(S,R,jpeg_info);  %获取嵌入代价
[M,N] = size(S);
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
filesize_propose = zeros(1,payload_length);
psnr_propose = zeros(1,payload_length);
ssim_propose = zeros(1,payload_length);
FSE_each = zeros(1,payload_length);
for k = 1:payload_length %
    carry = payload(k);
    rand('seed',9);Data = randi([0,1],1,carry); %随机生成的01比特作为秘密信息
    C=carry;

    [x1,g1] = intlinprog(E',1:M*N,-R',-C,[],[],zeros(M*N,1),ones(M*N,1)); %求出最优FSE
    disp('单目标');
    A = [-R';E'];
    alpha = 1;
    g = g1 + abs(alpha*g1);
    b = [-C;g];
    x=intlinprog(D',1:M*N,A,b,[],[],zeros(M*N,1),ones(M*N,1)); %单目标计算块决策变量，在满足FSE时的最优PSNR对应的决策变量
    %x为选中哪些块能满足条件
    x=uint8(reshape(x,M,N));
    %%
    %嵌入
    [S_stego] = jpeg_emdding_HS(Data,S,x);
    %%
    %得到载密图像
    stego_dct=cell2mat(S_stego);
    stego_jpeg_info = jpeg_info;
    stego_jpeg_info.coef_arrays{1,1} = stego_dct;   %修改后的DCT系数，写回JPEG信息
    filenamestego = strcat(filename,'_',num2str(carry));
    STEGO=['Stego\QF' num2str(QF) '\',filenamestego,'.jpg'];
    jpeg_write(stego_jpeg_info,STEGO);    %保存载密jpeg图像，根据解析信息，重构JPEG图像，获得载密图像
    
    %% 计算文件膨胀度与PSNR,SSIM
    fid=fopen(STEGO,'rb');
    bit1=fread(fid,'ubit1');
    fclose(fid);
    fid=fopen(ORIGINAL,'rb');
    bit2=fread(fid,'ubit1');
    fclose(fid);
    ZZ = (length(bit1) - length(bit2));
    I_stego = imread(STEGO);
    psnr_propose(k) = psnr(ori_jpeg,I_stego);
    ssim_propose(k) = SSIM(ori_jpeg,I_stego);
    FSE_each(1,k) = ZZ;
    filesize_propose(k) = ZZ/length(bit2)*100;
    
    %% 判断恢复是否正确
%     %提取
%     [S_re,exD] = jpeg_extract(S_stego,x,carry);
%     jpeg_re = jpeg_info;
%     jpeg_re.coef_arrays{1,1} = cell2mat(S_re);
%     jpeg_write(jpeg_re,'jpeg_re.jpg');%保存恢复jpeg图像
%     I_re = imread('jpeg_re.jpg');
%     psnr_re = psnr(ori_jpeg,I_re);
%     a = isequal(Data,exD);
%     if a == 1 && psnr_re == -1
%         disp(['第',num2str(k),'次提取正确且恢复正确']);
%     end
    
end
FSE_each(1,k+1) = length(bit2);%最后一个存放原始文件大小
PSNR_each = psnr_propose;
SSIM_each = ssim_propose;
psnr_sum = psnr_sum + psnr_propose;
filesize_sum = filesize_sum + filesize_propose;
ssim_sum = ssim_sum + ssim_propose;
r.name = filename;
r.psnr = PSNR_each;
r.ssim = SSIM_each;
r.FSE = FSE_each;
result{kkk} = r;
end
psnr_ave = psnr_sum/sum_imgNum;
filesize_ave = filesize_sum/sum_imgNum;
ssim_ave = ssim_sum/sum_imgNum;
%测试数据放入ave
save(['ave\payload_', num2str(QF), '.mat'],'payload');
save(['ave\psnr_', num2str(QF), '.mat'],'psnr_ave');
save(['ave\filesize_', num2str(QF), '.mat'],'filesize_ave');
save(['ave\ssim_', num2str(QF), '.mat'],'ssim_ave');

%每个的实验结果也放到ave_g512中
save(['ave\result_each', num2str(QF), '.mat'],'result');
end
toc