clear
a=0.036/2;b=1e-4/2;E=5.96e9;possion=0.15;lamda=0.6;alph=90*pi/180;stress=0:0.02:1;stress=stress*100e6;stress_spec=10e6;
beta=0:pi/13:2*pi;%这里更多的是椭圆内部的角度，不是椭圆倾斜的角度
G=E/(2*(1+possion));
k_p=(3-possion)/(1+possion);
f0=-(k_p+1)*(a*(1+lamda)-(1-lamda)*(a+b)*cos(2*alph))/(8*G);
e0=-(k_p+1)*((1-lamda)*(a+b)*sin(2*alph))/(8*G);
d0=-(k_p+1)*((-b)*(1+lamda)-(1-lamda)*(a+b)*cos(2*alph))/(8*G);
f=stress*f0;e=stress*e0;d=stress*d0;


%%以下两个是裂隙的裂纹面
 



lame_co=E*possion/((1+possion)*(1-2*possion));
%%我们是等比加载(闭合，李强)

poro=pi*(e0*stress).^2-(b+f0*stress).*(a-d0*stress)*pi;
%figure (2);plot(stress,poro/(2*a))
%figure (2);plot(stress,f,'c');hold on;plot(stress,e,'r');plot(stress,d,'k');legend('f','e','d')
clearvars -except stress poro a
figure (2);cm=40;cn=16;co=12;
for kk=1:cm
    if (poro(1,kk)>0)
        poro(1,kk)=0;
    end
end
plot(stress(1,1:cm),abs(poro(1,1:cm)),'rs');






