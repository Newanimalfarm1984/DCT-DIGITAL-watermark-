M =512;%原图像长度
N =64;%水印图像长度
K =8;%图像分块大小
I=zeros(M,M);%创建一个零矩阵，用于存放载体图像
J=zeros(N,N); %创建一个零矩阵，用于存放水印图像
BLOCK=zeros(K,K);%创建一个零矩阵，用于存放图像分块
%显示水印图像
%显示原图像
subplot(3,3,1);
I=imread('lena.bmp');
figure(1)
imshow(I);
title('原始公开图像');
%显示水印图像
iTimes=50;     %置乱次数
% 读入水印图像
file_name='a.png';%(随意换64*64的图片)
message=double(imread(file_name));
%水印图像矩阵的行数与列数
Mm=size(message,1);              
Nm=size(message,2);      
%对水印图像进行arnold置乱
if Mm~=Nm
  error('水印矩阵必须为方阵');
end
if Mm~=64
  error('必须为64*64大小,或者修改置乱次数');
end
tempImg=message; %图像矩阵赋给tempImg
for n=1:iTimes   %置乱次数
  for u=1:Mm   %行循环
    for v=1:Nm %列循环
      temp=tempImg(u,v);
      ax=mod((u-1)+(v-1),Mm)+1;   %新像素行位置
      ay=mod((u-1)+2*(v-1),Nm)+1;   %新像素列位置
      outImg(ax,ay)=temp;
    end
  end
tempImg=outImg;
end
% 显示水印，嵌入水印图像与原始图像
subplot(3,3,2);
figure(1)
imshow(message,[]);
title('原始水印');
subplot(3,3,3)
figure(1)
imshow(outImg,[]);
title('置乱水印');
%水印嵌入
for p=1:N%水印图像行循环
for q=1:N%水印图像列循环
x=(p-1)*K+1; %x为载体图像行坐标
y=(q-1)*K+1; %y为载体图像列坐标
BLOCK=I(x:x+K-1,y:y+K-1); %BLOCK为载体图像I的分块，分块大小为K*K，
%初始值为I(0:K-1,0:K-1)
BLOCK=dct2(BLOCK);%对BLOCK进行二维DCT变换，得到新的BLOCK即%DCT系数矩阵BLOCK
if J(p,q)==0%如果水印图像的第(p,q)个像素为0
a=-1;%嵌入参数为-1
else
a=1; %若如果水印图像的第(p,q)个像素为1嵌入参数为1
end
BLOCK(1,1)=BLOCK(1,1)*(1+a*0.1); %对应载体图像的分块的DCT系数矩阵
BLOCK=idct2(BLOCK);%对DCT系数矩阵进行反变换，得到嵌入水印后的载体
I(x:x+K-1,y:y+K-1)=BLOCK;%用嵌入水印后的图像分块BLOCK代替载体图像的对应分块
end
end
%显示嵌入水印后的图像
subplot(3,3,4);
figure(1)
imshow(I);
title('嵌入水印后的图像');
imwrite(I,'watermarked.bmp');
%从嵌入水印的图像中提取水印
I=imread('lena.bmp');
Q=imread('watermarked.bmp');
Q=imnoise(Q,'gaussian',0,0.001);
subplot(3,3,5);
figure(1)
imshow(Q,[]);
title('加入高斯噪声');
for p=1:N
for q=1:N
x=(p-1)*K+1;
y=(q-1)*K+1;
BLOCK1 =I(x:x+K-1,y:y+K-1);%赋给BLOCK1元素
BLOCK2 =Q(x:x+K-1,y:y+K-1);%赋给BLOCK2元素
BLOCK1=dct2(BLOCK1);
BLOCK2=dct2(BLOCK2);
a = BLOCK2(1,1)/BLOCK1(1,1)-1;
if a<0
W(p,q)=0;
else
W(p,q)=1;
end
end
end
%显示提取的水印
subplot(3,3,6);
figure(1)
imshow(W);
title('从含水印图像中提取的水印'); 
% arnold反置乱
message_arnold=tempImg;
iTimes1=48-iTimes;
%置乱后水印图像矩阵的行数与列数
Mo=size(outImg,1);              
No=size(outImg,2);     
for n=1:iTimes1 % 次数
  for u=1:Mo
    for v=1:No
      temp1=tempImg(u,v);
      bx=mod((u-1)+(v-1),Mo)+1;
      by=mod((u-1)+2*(v-1),No)+1;
      outImg1(bx,by)=temp1;
    end
  end
tempImg=outImg1;
end
% 显示反置乱后水印
subplot(3,3,7);
figure(1)
imshow(message,[]);
title('反置乱(恢复)水印');

   % 旋转攻击
   P3=imread('watermarked.bmp');
P3=imrotate(P3,90);%逆时针旋转90度;
figure(2)
subplot(2,3,1);
imshow(P3,[]);
title('旋转攻击');
figure(2);
I3=imread('lena.bmp');%未加水印的原图像
I3=imrotate(I3,90); %原图像逆时针旋转90度;
%提取水印算法
for p=1:N
for q=1:N
x=(p-1)*K+1;
y=(q-1)*K+1;
BLOCK1=I3(x:x+K-1,y:y+K-1);%赋给BLOCK1元素
BLOCK2=P3(x:x+K-1,y:y+K-1);%赋给BLOCK2元素
BLOCK1=idct2(BLOCK1);%对其本身进行反二维离散余弦变换
BLOCK2=idct2(BLOCK2);%对其本身进行反二维离散余弦变换
a=BLOCK2(1,1)/BLOCK1(1,1)-1;
if a<0
W3(p,q)=0;
else
W3(p,q)=1;
end
end
end

% arnold反置乱
message_arnold=tempImg;
iTimes1=48-iTimes;
%置乱后水印图像矩阵的行数与列数
Mo=size(outImg,1);              
No=size(outImg,2);     
for n=1:iTimes1 % 次数
  for u=1:Mo
    for v=1:No
      temp1=tempImg(u,v);
      bx=mod((u-1)+(v-1),Mo)+1;
      by=mod((u-1)+2*(v-1),No)+1;
      outImg1(bx,by)=temp1;
    end
  end
tempImg=outImg1;
end
% 显示反置乱后水印
subplot(2,3,2);
figure(2)
imshow(message_arnold,[]);
title('提取的置乱水印');
subplot(2,3,3);
figure(2)
imshow(message,[]);
title('反置乱(恢复)水印');

%变小攻击
J=imread('watermarked.bmp');
P2=imresize(J,0.5);%变为0.5倍，从512x512到256x256
figure(3);
subplot(2,3,1);
figure(3);
imshow(P2,[]);%显示变小后图像
title('变小攻击');
I2=imread('lena.bmp');%未加水印的原图像
I2=imresize(I2,0.5);%原图像一样变小
%提取水印算法
for p=1:64
for q=1:64
x=(p-1)*4+1;
y=(q-1)*4+1;
BLOCK1=I2(x:x+4-1,y:y+4-1);%赋给BLOCK1元素
BLOCK2=P2(x:x+4-1,y:y+4-1);%赋给BLOCK2元素
BLOCK1=idct2(BLOCK1);%对其本身进行反二维离散余弦变换
BLOCK2=idct2(BLOCK2);%对其本身进行反二维离散余弦变换
a=BLOCK2(1,1)/BLOCK1(1,1)-1;
if a<0
W(p,q)=0;
else
W(p,q)=1;
end
end
end
% arnold反置乱
message_arnold=tempImg;
iTimes1=48-iTimes;
%置乱后水印图像矩阵的行数与列数
Mo=size(outImg,1);              
No=size(outImg,2);     
for n=1:iTimes1 % 次数
  for u=1:Mo
    for v=1:No
      temp1=tempImg(u,v);
      bx=mod((u-1)+(v-1),Mo)+1;
      by=mod((u-1)+2*(v-1),No)+1;
      outImg1(bx,by)=temp1;
    end
  end
tempImg=outImg1;
end
% 显示反置乱后水印
subplot(2,3,2);
figure(3)
imshow(message_arnold,[]);
title('提取的置乱水印');
subplot(2,3,3);
figure(3)
imshow(message,[]);
title('反置乱(恢复)水印');

%中指滤波攻击
P1=imread('watermarked.bmp');
P1=double(P1(:,:,1));%取1通道
figure(4)
P1=medfilt2(P1);%中值滤波
subplot(2,3,1);
imshow(P1,[]);
title('中值滤波攻击');
figure(4);
I1=imread('lena.bmp');%未加水印的原图像
%提取水印算法
for p=1:N
for q=1:N
x=(p-1)*K+1;
y=(q-1)*K+1;
BLOCK1=I1(x:x+K-1,y:y+K-1);%赋给BLOCK1元素
BLOCK2=P1(x:x+K-1,y:y+K-1);%赋给BLOCK2元素
BLOCK1=idct2(BLOCK1);%对其本身进行反二维离散余弦变换
BLOCK2=idct2(BLOCK2);%对其本身进行反二维离散余弦变换
a=BLOCK2(1,1)/BLOCK1(1,1)-1;
if a<0
W1(p,q)=0;
else
W1(p,q)=1;
end
end
end

% arnold反置乱
message_arnold=tempImg;
iTimes1=48-iTimes;
%置乱后水印图像矩阵的行数与列数
Mo=size(outImg,1);              
No=size(outImg,2);     
for n=1:iTimes1 % 次数
  for u=1:Mo
    for v=1:No
      temp1=tempImg(u,v);
      bx=mod((u-1)+(v-1),Mo)+1;
      by=mod((u-1)+2*(v-1),No)+1;
      outImg1(bx,by)=temp1;
    end
  end
tempImg=outImg1;
end
% 显示反置乱后水印
subplot(2,3,2);
figure(4)
imshow(message_arnold,[]);
title('提取的置乱水印');
subplot(2,3,3);
figure(4)
imshow(message,[]);
title('反置乱(恢复)水印');
% 对图像进行JPEG压缩攻击　
subplot(2,3,1);
figure(5)
L=imread( 'watermarked.bmp');
imwrite (L,'xx.bmp','jpeg','Quality',50);
L=imread('watermarked.bmp');
subplot(2,3,1);
figure(5)
imshow(L);
title('压缩攻击后的图像')
I1=imread('lena.bmp');%未加水印的原图像
%提取水印算法
for p=1:N
for q=1:N
x=(p-1)*K+1;
y=(q-1)*K+1;
BLOCK1=I1(x:x+K-1,y:y+K-1);%赋给BLOCK1元素
BLOCK2=L(x:x+K-1,y:y+K-1);%赋给BLOCK2元素
BLOCK1=idct2(BLOCK1);%对其本身进行反二维离散余弦变换
BLOCK2=idct2(BLOCK2);%对其本身进行反二维离散余弦变换
a=BLOCK2(1,1)/BLOCK1(1,1)-1;
if a<0
W1(p,q)=0;
else
W1(p,q)=1;
end
end
end
% arnold反置乱
message_arnold=tempImg;
iTimes1=48-iTimes;
%置乱后水印图像矩阵的行数与列数
Mo=size(outImg,1);              
No=size(outImg,2);     
for n=1:iTimes1 % 次数
  for u=1:Mo
    for v=1:No
      temp1=tempImg(u,v);
      bx=mod((u-1)+(v-1),Mo)+1;
      by=mod((u-1)+2*(v-1),No)+1;
      outImg1(bx,by)=temp1;
    end
  end
tempImg=outImg1;
end
% 显示反置乱后水印
subplot(2,3,2);
figure(5)
imshow(message_arnold,[]);
title('提取的置乱水印');
subplot(2,3,3);
figure(5)
imshow(message,[]);
title('反置乱(恢复)水印');

%抖动攻击
X=imread('watermarked.bmp');
figure(6)
BW = dither(X);%中值滤波
subplot(2,3,1);
imshow(BW,[]);
title('抖动攻击');
figure(6);
I1=imread('lena.bmp');%未加水印的原图像
%提取水印算法
for p=1:N
for q=1:N
x=(p-1)*K+1;
y=(q-1)*K+1;
BLOCK1=I1(x:x+K-1,y:y+K-1);%赋给BLOCK1元素
BLOCK2=X(x:x+K-1,y:y+K-1);%赋给BLOCK2元素
BLOCK1=idct2(BLOCK1);%对其本身进行反二维离散余弦变换
BLOCK2=idct2(BLOCK2);%对其本身进行反二维离散余弦变换
a=BLOCK2(1,1)/BLOCK1(1,1)-1;
if a<0
W1(p,q)=0;
else
W1(p,q)=1;
end
end
end
% arnold反置乱
message_arnold=tempImg;
iTimes1=48-iTimes;
%置乱后水印图像矩阵的行数与列数
Mo=size(outImg,1);              
No=size(outImg,2);     
for n=1:iTimes1 % 次数
  for u=1:Mo
    for v=1:No
      temp1=tempImg(u,v);
      bx=mod((u-1)+(v-1),Mo)+1;
      by=mod((u-1)+2*(v-1),No)+1;
      outImg1(bx,by)=temp1;
    end
  end
tempImg=outImg1;
end
% 显示反置乱后水印
subplot(2,3,2);
figure(6)
imshow(message_arnold,[]);
title('提取的置乱水印');
subplot(2,3,3);
figure(6)
imshow(message,[]);
title('反置乱(恢复)水印');

























