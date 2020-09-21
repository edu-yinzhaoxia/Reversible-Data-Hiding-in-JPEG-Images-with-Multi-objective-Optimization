clear
clc
addpath jpegread\;
% addpath utils\;
dbstop if error  %出现错误的时候保留数据

addpath(genpath('E:\MATLABR2016bworkspace\data set\g512\'));
filePath = 'E:\MATLABR2016bworkspace\data set\g512\';%图像库路径
imgPathList = dir(strcat(filePath,'\*.pgm'));% 获取所有质量因子为QF的jpg图像
imgNum = length(imgPathList);% 获取图像总量
for QF=30:20:90                 %选择不同的QF进行处理
    %给定payload的步长
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
filesize_sum = zeros(1,payload_length);
ssim_sum = zeros(1,payload_length);
sum_imgNum = imgNum;    %记录符合选定最大payload的图像的个数
for i=1:imgNum %选择每一张图片
filename = imgPathList(i).name;
imwrite(uint8(imread(filename)),strcat('name',num2str(QF),'.jpg'),'jpg','quality',QF);      %在当前QF下压缩
filename1=strcat('name',num2str(QF),'.jpg');
%% 解析JPEG文件
ORIGINAL = filename1;
jpeg_info = jpeg_read(ORIGINAL);%解析JPEG图像
jobj = jpeg_info;
dct=jobj.coef_arrays{1};                           %存dct系数 
sum_R = sum_payload(dct);
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
[best,FSE]=synthesize(filename,jobj,payload,ORIGINAL,QF);%实现最优选择的嵌入
FSE_each = FSE;
PSNR_each = best(2,:);
SSIM_each = best(3,:);
psnr_sum = psnr_sum + best(2,:);
ssim_sum = ssim_sum + best(3,:);
filesize_sum = filesize_sum + best(4,:);
x.name = filename;
x.psnr = PSNR_each;
x.ssim = SSIM_each;
x.FSE = FSE_each;
result{i} = x;
end
psnr_ave = psnr_sum/sum_imgNum;
filesize_ave = filesize_sum/sum_imgNum;
ssim_ave = ssim_sum/sum_imgNum;
%测试数据放入ave
save(['ave\payload_', num2str(QF), '.mat'],'payload');
save(['ave\psnr_', num2str(QF), '.mat'],'psnr_ave');
save(['ave\filesize_', num2str(QF), '.mat'],'filesize_ave');
save(['ave\ssim_', num2str(QF), '.mat'],'ssim_ave');

%每个的实验结果也放到ave_ucid中
save(['ave\result_each', num2str(QF), '.mat'],'result');
end
poolobj = gcp('nocreate');
delete(poolobj);