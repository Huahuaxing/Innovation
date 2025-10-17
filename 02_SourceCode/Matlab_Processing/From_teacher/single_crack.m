clear;clc;
aa=load('D:\BaiduSyncdisk\paper 004-拾峰师兄\data\area-1-bluntered-crack.txt');
for kk=1:size(aa,1)
    if (aa(kk,2)<0)
        aa(kk,2)=0;
    end
end
figure (1)
plot(aa(:,1),aa(:,2),'c');hold on

clear;
aa=load('D:\BaiduSyncdisk\paper 004-拾峰师兄\data\area-1-elliptical-crack.txt');
for kk=1:size(aa,1)
    if (aa(kk,2)<0)
        aa(kk,2)=0;
    end
end

plot(aa(:,1),aa(:,2),'r');legend('Nonelliptical','Elliptical')