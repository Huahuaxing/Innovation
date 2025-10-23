if __name__ == "__main__":
    x = np.arange(-c0, c0 + 0.001, 0.001)

    bigCrack = Pcrack(2e-4/2, 0.036/2, 7.82e9, 0.23)
    smallCrack = Pcrack(1e-4/2, 0.036/2, 7.82e9, 0.23)

    bigCrack.sigma_close()
    smallCrack.sigma_close()

    print(f"椭圆裂隙的闭合应力为：{sigma_close_e(b, c0, E, nu)/1e6} MPa")
    print(f"非椭圆裂隙A的闭合应力为：{sigma_close_p(b, c0, E, nu)/1e6} MPa")

    # 面积求解
    A = np.zeros(len(P))
    for i in range(len(P)):
        c = c_of_P(P[i], b, c0, nu, mu0)
        A[i] = quad(lambda x_val: integrand(x_val, c, b, c0), -c, c)[0]

    # 图像1:裂隙随应力变化的图像
    P_subset = P[::5]  # 每10个取一个
    c1 = c_of_P(P_subset, b, c0, nu, mu0)
    A3 = A[::5]

    fig = plt.figure(figsize=(14, 10), constrained_layout=True)
    gs = fig.add_gridspec(nrows=len(P_subset), ncols=2, width_ratios=[1, 1])

    # 右侧大图：应力-面积（占两列的所有行）
    ax_right = fig.add_subplot(gs[:, 1])
    ax_right.plot(P/1e6, A*1e6, 'b-', linewidth=2)
    ax_right.set_xlabel('Stress P (MPa)')
    ax_right.set_ylabel('Area (mm^2)')
    ax_right.set_title('Area vs Stress')
    ax_right.grid(True)

    # 左侧 10 个小图（上到下）
    for i, ci in enumerate(c1):
        ax = fig.add_subplot(gs[i, 0])
        U1 = integrand(x, ci, b, c0)
        ax.plot(x, U1/2, 'b-')
        ax.plot(x, -U1/2, 'b-')
        ax.set_title(f"P={P_subset[i]/1e6:.2f} MPa  A={A3[i]*1e6:.3f} mm$^2$")
        ax.grid(True)
        ax.set_ylim(-6e-5, 6e-5)
        # 只在最下面的小图显示 x 轴标签
        if i < len(c1)-1:
            ax.set_xticklabels([])
    plt.show()