%% cftool_exp_vp_fit.m : 使用 cftool 拟合 Stress-Vp 数据
clear; clc; close all;
cd(fileparts(mfilename('fullpath')));

prop = jsondecode(fileread('properties.json'));
nonellipse_vp_path = fullfile('.\degree_90\vp_polygonal.csv');
nonellipse_de0_vp = readmatrix(nonellipse_vp_path);

cycle = 1;  % 数据组数
indices = [1, 5, 4, 3, 2, 6];
titles = {'20AR1', '16AR1+4AR2', '12AR1+8AR2', '8AR1+12AR2', '4AR1+16AR2', '20AR2'};

figure('Units','centimeters','Position',[2 2 40 18]);

for i = 1:cycle
    % 确保是列向量
    xData = prop.P(:);
    yData = nonellipse_de0_vp(:,indices(i));
    
    % 拟合模型
    ft = fittype('A + K*x - B*exp(-x*D)', ...
        'independent','x','coefficients',{'A','K','B','D'});
    
    % 调整初始值，防止发散
    opts = fitoptions('Method','NonlinearLeastSquares');
    opts.StartPoint = [2000, 1e-8, 100, 1e-8];
    opts.Lower = [0, -Inf, 0, 0];  % 可以避免出现负指数或负参数
    opts.MaxIter = 2000;
    
    [fitresult, gof] = fit(xData, yData, ft, opts);
    
    subplot(2,3,i)
    plot(xData, yData, 'r.', 'MarkerSize', 12); hold on;
    h = plot(fitresult, 'b-', 'LineWidth',1.6);
    legend(h, sprintf('A=%.2f, K=%.2e, B=%.2f, D=%.2e, R^2=%.4f', ...
        fitresult.A, fitresult.K, fitresult.B, fitresult.D, gof.rsquare), ...
        'Location', 'best');
    
    xlabel('Uniaxial Stress (Pa)');
    ylabel('v_p (m/s)');
    title(titles{i});
    grid on; box on;
end
