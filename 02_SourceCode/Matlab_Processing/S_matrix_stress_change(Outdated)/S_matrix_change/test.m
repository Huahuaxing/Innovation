%% 数据初始化
clear;
cd(fileparts(mfilename("fullpath")));
params = jsondecode(fileread("../../../../06_ProcessedData/parameters.json"));
P = params.P;
% 横观各向同性刚度矩阵，C11=C22,有五个独立分量C11，C12，C13，C33，C44
ellipseS = zeros(200,5,6,6,6);
ellipse_C_eff = load("../../../../06_ProcessedData/ellipse_C_eff.mat");  % (200, 5, 6, 6, 6)，200个应力，5个子模型，6*6刚度矩阵，6组模型
ellipseC = ellipse_C_eff.C_eff_ellipse;
for g=1:6
    for s=1:5
        for p=1:200
            S = inv(squeeze(ellipseC(p,s,:,:,g)));
            ellipseS(p,s,:,:,g) = S;
        end
    end
end

ellipseS_a = squeeze(mean(ellipseS, 2)); % 对五个子模型求平均值

%% 拟合区
S_params = zeros(6,2);
initialParams = [1, 1];
opts = optimset('Display', 'on', ...
                'MaxIter', 10000, ...
                'MaxFunEvals', 10000, ...
                'TolFun', 1e-8, ...
                'TolX', 1e-8);


% model_func = @(params, P) S_fit(params, P);

for g=3:3
    [params, resnorm] = lsqcurvefit(@(params, P) S_fit(params, P), initialParams, P, ellipseS_a(:,3,3,1), [], [], opts);
    S_params(g,:) = params;
end

%% 绘图区
% figure("Position", [0,0,2500,500]);
% titlesList = {"a11", "a12", "a13", "a33", "a44"};
% for c=1:5
%     switch c
%         case 1
%             subplot(1,5,c);
%             plot(P,ellipseS_a(:,1,1,1));
%             title(titlesList{c});
%         case 2
%             subplot(1,5,c);
%             plot(P,ellipseS_a(:,1,2,1));
%             title(titlesList{c});
%         case 3
%             subplot(1,5,c);
%             plot(P,ellipseS_a(:,1,3,1));
%             title(titlesList{c});
%         case 4
%             subplot(1,5,c);
%             plot(P,ellipseS_a(:,3,3,1));
%             title(titlesList{c});
%         case 5
%             subplot(1,5,c);
%             plot(P,ellipseS_a(:,4,4,1));
%             title(titlesList{c});
%     end
% end

S33Fitting = S_fit(S_params, P);
figure;
% scatter(P(1:3:end), ellipseS_a(1:3:end,3,3,1))
plot(P, S33Fitting)

%% 函数区
function S = S_fit(params, P)
    a = params(1);
    b = params(2);
    S = a + b .* P;
end
