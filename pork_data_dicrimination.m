clc
clear all
close all
%% 导入数据

X_hlh=xlsread('C:\Users\hasee\Desktop\新猪肉第一批检测程序\新猪肉第一批检测程序\健康猪肉1.xls')';   
X_ded=xlsread('C:\Users\hasee\Desktop\新猪肉第一批检测程序\新猪肉第一批检测程序\病死猪肉1.xls')';


X_hlh=[X_hlh;xlsread('C:\Users\hasee\Desktop\新猪肉第一批检测程序\新猪肉第一批检测程序\好猪肉.xls')'];
X_ded=[X_ded;xlsread('C:\Users\hasee\Desktop\新猪肉第一批检测程序\新猪肉第一批检测程序\坏猪肉.xls')'];
% porkdata=[X_hlh;X_ded];
% porkdata=msc(porkdata);
X_hlh=msc(X_hlh);
% X_ded=msc(X_ded);
porkdata=snv(porkdata);
X_hlh=snv(X_hlh);
% X_ded=snv(X_ded);
%  
%  X_hlh2=xlsread('C:\Users\hasee\Desktop\新猪肉第一批检测程序\新猪肉第一批检测程序\健康猪肉2.xls')';
%  X_ded2=xlsread('C:\Users\hasee\Desktop\新猪肉第一批检测程序\新猪肉第一批检测程序\病死猪肉2.xls')';

porkdata=nirmaf(porkdata,11);                          %光谱预处理

Spec_point=xlsread('C:\Users\hasee\Desktop\新猪肉第一批检测程序\新猪肉第一批检测程序\specpoint.xls')';
 [COEFF,pca,latent] = pca([X_hlh;X_ded]);
 m=randperm(63);
 n=randperm(46);
% train_data=[pca(m1n(1:53),1:5);pca(m2(1:35),1:5)];
% test_data=[pca(m1(54:63),1:5);pca(m2(36:46),1:5)];
X_hlh=porkdata(1:63,:);
X_ded=porkdata(64:end,:);


fft_hlh=(abs(fft(X_hlh')))';                     %光谱信号傅里叶变换
fft_ded=(abs(fft(X_ded')))';                     %主成分分析
% subplot(2,1,1)
% plot(fft_hlh(2:101,:));
% subplot(2,1,2)
% plot(fft_ded(2:101,:));
% label=[ones(1,63) zeros(1,46)];
ptrain=[];ptest=[];acctrain=[];acctest=[];

tic   
%   for i=1:20
 %一共进行十次这样的抽取
    %随机取46个新鲜猪肉、32个病死猪肉光谱作为Training set
    %随机取17个健康猪肉、14个病死猪肉光谱作为Validation set
   
train_data=[fft_hlh(m(1:48),2:16);fft_ded(n(1:33),2:16)];
test_data=[fft_hlh(m(49:end),2:16);fft_ded(n(34:end),2:16)];
train_label=[ones(48,1);2*ones(33,1)];
test_label=[ones(15,1);2*ones(13,1)];
[bestacc,bestc,bestg]=SVMcgForClass(train_label,train_data,1,30,-35,-1,5,0.5,0.5);
%     构建并训练SVM模型
        model=svmtrain(train_label,train_data,'-s 0 -t 2 -c 1048576 -g 5.394796609394436e-06');
      
       [ptrainlabel,acctrain]=svmpredict(train_label,train_data,model);
       [ptestlabel,acctest]=svmpredict(test_label,test_data,model);
       num_jiankang=sum(ptestlabel(1:16,:)==1);
       num_sizhurou=sum(ptestlabel(17:end,:)==2);
       jiankang=num_jiankang/16;
       sizhurou=num_sizhurou/13;
  fprintf('健康猪肉判别正确率：%f%% (%d/16)\n',jiankang*100,num_jiankang);
  fprintf('病死猪肉判别正确率：%f%% (%d/13)\n',sizhurou*100,num_sizhurou);
