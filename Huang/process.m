function [psnrTable,increaseTable] = process(name,QF)
addpath JPEG_Toolbox\;
addpath img\;

imwrite(imread(name),'ori.jpg','jpeg','quality',QF); %生成QF为XX的ori.jpg
ori_jpeg_info = jpeg_read('ori.jpg');%解析JPEG图像
oridct = ori_jpeg_info.coef_arrays{1,1}; %获取dct系数
maxlen = length(find(oridct==1)) + length(find(oridct==-1))-500; %获取最大嵌入长度

if QF==20
    sss=1000;
    eee=min(maxlen,10000);
elseif QF==40
    sss=1000;
    eee=min(maxlen,12000);
elseif QF==60
    sss=2000;
    eee=min(maxlen,20000);
else
    sss=2000;
    eee=min(maxlen,24000);
end
    

cnt1=1;
for nn=sss:sss:eee
rng(100,'twister');
data = round(rand(1,nn)*1);%随机产生01比特，作为嵌入的数据
payload = nn; %嵌入容量控制变量

imwrite(imread(name),'ori.jpg','jpeg','quality',QF);
jpeg_info = jpeg_read('ori.jpg');
quant_tables = jpeg_info.quant_tables{1,1}; %获取量化表
oridct = jpeg_info.coef_arrays{1,1};  %获取dct系数
oriBlockdct = mat2cell(oridct,8 * ones(1,512/8),8 * ones(1,512/8)); %把原来的图像矩阵分割成N个8*8的Block

[zeronum] = Getzeronum(oriBlockdct);

%嵌入函数
[emdData,numData,jpeg_info_stego] = jpeg_emdding(data,oriBlockdct,jpeg_info,payload,zeronum); 

jpeg_write(jpeg_info_stego,'stego.jpg');%保存载密jpeg图像，根据解析信息，重构JPEG图像

%获取PSNR和文件增量
ori_jpeg = imread('ori.jpg');%读取原始jpeg图像
stego_jpeg = imread('stego.jpg');%读取载密jpeg图像
psnrTable(cnt1)=psnr(ori_jpeg,stego_jpeg);

fid=fopen('stego.jpg','rb');
bit1=fread(fid,'ubit1');
fclose(fid);
fid=fopen('ori.jpg','rb');
bit2=fread(fid,'ubit1');
fclose(fid);
increaseTable(cnt1) = length(bit1)-length(bit2);

cnt1=cnt1+1;
end
if cnt1==1
    psnrTable=[0,0];
    increaseTable=[0,0];
end
end