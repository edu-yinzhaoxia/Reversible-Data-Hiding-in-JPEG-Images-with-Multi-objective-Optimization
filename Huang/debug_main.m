clear;
clc;
addpath JPEG_Toolbox\;
addpath(genpath('E:\MATLABR2016bworkspace\data set\g512\'));
filePath = 'E:\MATLABR2016bworkspace\data set\g512\';%UCID图像库路径
imgPathList = dir(strcat(filePath,'\*.pgm'));% 获取所有pgm图像
imgNum = length(imgPathList);% 获取pgm图像总量
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
payload_length = length(payload);
psnr_sum = zeros(1,payload_length);
filesize_sum = zeros(1,payload_length);
ssim_sum = zeros(1,payload_length);
sum_imgNum = imgNum;
result = cell(imgNum,1);
for kkk = 1:imgNum
    filename = imgPathList(kkk).name;
imwrite(uint8(imread(filename)),strcat('name',num2str(QF),'.jpg'),'jpg','quality',QF);      %在当前QF下压缩
filename1=strcat('name',num2str(QF),'.jpg');
ORIGINAL = filename1;
jpeg_info = jpeg_read(ORIGINAL);%解析JPEG图像
ori_jpeg = imread(ORIGINAL);%读取原始jpeg图像
quant_tables = jpeg_info.quant_tables{1,1}; %获取量化表
oridct = jpeg_info.coef_arrays{1,1};  %获取dct系数
sum_R = sum_payload(oridct);
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
[M,N] = size(oridct);
oriBlockdct = mat2cell(oridct,8 * ones(1,M/8),8 * ones(1,N/8)); %把原来的图像矩阵分割成N个8*8的Block
[M,N] = size(oriBlockdct);
[zeronum] = Getzeronum(oriBlockdct);
psnr_Huang = zeros(1,payload_length);
filesize_Huang = zeros(1,payload_length);
ssim_Huang = zeros(1,payload_length);
FSE_each = zeros(1,payload_length+1);
cnt1=1;
for k = 1:payload_length %
nn = payload(k);
rng(100,'twister');
data = round(rand(1,nn)*1);%随机产生01比特，作为嵌入的数据
%嵌入函数
[jpeg_info_stego] = jpeg_emdding(data,oriBlockdct,jpeg_info,nn,zeronum); 
filenamestego = strcat(filename,'_',num2str(nn));
STEGO=['Stego\QF' num2str(QF) '\',filenamestego,'.jpg'];
jpeg_write(jpeg_info_stego,STEGO);    %保存载密jpeg图像，根据解析信息，重构JPEG图像，获得载密图像

%% 提取信息
% [re_jpeg_info,extData] = jpeg_extract(jpeg_info_stego,nn,zeronum);
% jpeg_write(re_jpeg_info,'re.jpg');%保存图像，根据解析信息，重构JPEG图像
% re_jpeg = imread('re.jpg');%读取载密jpeg图像
% a = isequal(extData,data);
% %获取PSNR和文件增量
% a_psnr_H=psnr(ori_jpeg,re_jpeg);
% if a == 1 && a_psnr_H == -1
%     disp('success');
% end
stego_jpeg = imread(STEGO);%读取载密jpeg图像
psnr_Huang(k)=psnr(ori_jpeg,stego_jpeg);
ssim_Huang(k) = SSIM(ori_jpeg,stego_jpeg);
fid=fopen(STEGO,'rb');
bit1=fread(fid,'ubit1');
fclose(fid);
fid=fopen(ORIGINAL,'rb');
bit2=fread(fid,'ubit1');
fclose(fid);
ZZ = (length(bit1)-length(bit2));
FSE_each(1,k) = ZZ;
filesize_Huang(k) = ZZ/length(bit2)*100;
end
FSE_each(1,k+1) = length(bit2);%最后一个存放原始文件大小
PSNR_each = psnr_Huang;
SSIM_each = ssim_Huang;
psnr_sum = psnr_sum + psnr_Huang;
filesize_sum = filesize_sum + filesize_Huang;
ssim_sum = ssim_sum + ssim_Huang;
x.name = filename;
x.psnr = PSNR_each;
x.ssim = SSIM_each;
x.FSE = FSE_each;
result{kkk} = x;
end
ave_psnr = psnr_sum/sum_imgNum;
ave_filesize = filesize_sum/sum_imgNum;
ssim_ave = ssim_sum/sum_imgNum;

%测试数据放入ave
save(['ave\payload_', num2str(QF), '.mat'],'payload');
save(['ave\psnr_', num2str(QF), '.mat'],'ave_psnr');
save(['ave\filesize_', num2str(QF), '.mat'],'ave_filesize');
save(['ave\ssim_', num2str(QF), '.mat'],'ssim_ave');

%每个的实验结果也放到ave_ucid中
save(['ave\result_each', num2str(QF), '.mat'],'result');
end