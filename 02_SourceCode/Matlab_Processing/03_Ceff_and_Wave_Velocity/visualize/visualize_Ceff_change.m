% C_eff矩阵是横向各向同性矩阵，独立分量有五个，分别是C11，C12，C13，C33，C44
% 五幅大图，每幅大图里面是代表六组的六个子图

%% 绘图设置
modelParams = {'20AR1', '16AR1+4AR2', '12AR1+8AR2', '8AR1+12AR2', '4AR1+16AR2', '20AR2'};
subTitleList = {'(a)', '(b)', '(c)', '(d)', '(e)', '(f)'};

% 图像保存路径设置
saveBaseDir = '.\Research\02_C_eff_and_Velocity\Figure\n20_degree_0';
saveDir    = fullfile(saveBaseDir, 'contain_aligned');
saveDirNot = fullfile(saveBaseDir, 'not_contain_aligned');
if ~exist("saveDir", 'dir');    mkdir(saveDir); end
if ~exist("saveDirNot", 'dir');    mkdir(saveDirNot); end


%% 数据读取
params = jsondecode(fileread('.\06_ProcessedData\parameters.json'));
P = params.P / 1e6;
C_eff_Ellipse = load(".\06_ProcessedData\02_C_eff\ellipse_C_eff.mat");                  % 200,5,6,6,6
C_eff_EllipseAligned= load(".\06_ProcessedData\02_C_eff\ellipseAligned_C_eff.mat");
C_eff_Nonellipse = load(".\06_ProcessedData\02_C_eff\Nonellipse_C_eff.mat");
C_eff_Ellipse = C_eff_Ellipse.C_eff_ellipse;
C_eff_EllipseAligned = C_eff_EllipseAligned.C_eff_ellipseAligned;
C_eff_Nonellipse = C_eff_Nonellipse.C_eff_nonellipse;

C_eff_Ellipse_mean = squeeze(mean(C_eff_Ellipse, 2));
C_eff_EllipseAligned_mean = squeeze(mean(C_eff_EllipseAligned, 2));
C_eff_Nonellipse_mean = squeeze(mean(C_eff_Nonellipse, 2));



C11_Ellipse = C_eff_Ellipse_mean
C11_EllipseAligned
C11_Nonellipse


%% 绘图区
% 一幅大图，五个子图，第一行两个子图，第二行三个子图，均匀分布，大小相等
subfigureW = 0.26;
subfigureH = 0.32;
x1 = 0.5 - subfigureW -0.02;
x2 = 0.5 + 0.02;
y_top = 0.60;

gap = (1 - 3 * subfigureW) / 4;
x3 = gap;
x4 = 2 * gap + subfigureW;
x5 = 3 * gap + 2 * subfigureW;
y_bot = 0.15;

figure('Position', [100 100 2000 1000]);
sgtitle('Uniaxial Stress-C_{eff}', 'FontSize', 14, 'FontWeight','bold');

% 5个刚度分量
component_names = {'C_{11}', 'C_{12}', 'C_{13}', 'C_{33}', 'C_{44}'};
ax = gobjects(1,5);

for group = 1:5
    
    % --- 位置控制 ---
    if group == 1
        pos = [x1 y_top subfigureW subfigureH];
    elseif group == 2
        pos = [x2 y_top subfigureW subfigureH];
    elseif group == 3
        pos = [x3 y_bot subfigureW subfigureH];
    elseif group == 4
        pos = [x4 y_bot subfigureW subfigureH];
    else
        pos = [x5 y_bot subfigureW subfigureH];
    end
    
    % --- 创建子图 ---
    ax(group) = axes('Position', pos);
    hold on; grid on;
    
    % --- 画图 ---
    plot(P, C_eff_Ellipse(:, group), 'b-', 'LineWidth', 1.5);
    plot(P, C_eff_EllipseAligned(:, group), 'g-', 'LineWidth', 1.5);
    plot(P, C_eff_Nonellipse(:, group), 'r-', 'LineWidth', 1.5);
    
    % --- 标题和标签 ---
    title(component_names{group}, 'FontSize', 12, 'FontWeight','bold');
    xlabel('Uniaxial Stress (MPa)', 'FontSize', 11);
    ylabel('Stiffness (GPa)', 'FontSize', 11);
    
    % --- 图例只放一个 ---
    if group == 1
        legend({'Ellipse','Aligned','Nonellipse'}, ...
            'FontSize',9,'Location','southeast');
    end
end

% 坐标轴联动
linkaxes(ax, 'xy');

% saveas(gcf, fullfile(saveDir, 'Uniaxial Stress-P Velocity.fig'));
% saveas(gcf, fullfile(saveDir, 'Uniaxial Stress-P Velocity.png'));

% % not contain algned
% figure('Position', [100 100 2000 1000]);
% sgtitle('Uniaxial Stress-C_eff', 'FontSize', 14, 'FontWeight','bold');
% ax = gobjects(1, 6);
% for group=1:6
%     ax(group) = subplot(2, 3, group);
%     title(subTitleList{group}, 'FontSize', 12, 'FontWeight','normal');
%     hold on;
%     plot(P, vpEllipse(:, group), 'b-', 'LineWidth', 1.5);
%     plot(P, vpNonellipse(:, group), 'r-', 'LineWidth', 1.5);
%     xlabel('Uniaxial Stress (MPa)', 'FontSize', 11);
%     ylabel('V_p (m/s)', 'FontSize', 11);
%     if group == 1
%         legend({'Ellipse model', 'Nonelliptical model'}, 'FontSize', 9, 'Location', 'southeast');
%     end
%     text(0.5, 0.07, modelParams{group}, ...
%         'Units','normalized', ...          % 使用子图归一化坐标
%         'FontSize', 10, 'FontWeight', 'bold', ...
%         'HorizontalAlignment', 'center', ...
%         'VerticalAlignment', 'top', ...
%         'BackgroundColor', [1 1 1 0.8], ...
%         'EdgeColor', 'k', 'LineWidth', 0.5, ...
%         'Margin', 2);
%     set(gca, 'FontName', 'SimHei', 'FontSize', 11);
% end
% linkaxes(ax, 'xy'); 

% saveas(gcf, fullfile(saveDirNot, 'Uniaxial Stress-P Velocity.fig'));
% saveas(gcf, fullfile(saveDirNot, 'Uniaxial Stress-P Velocity.png'));