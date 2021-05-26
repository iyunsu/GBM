function [Vp0,rho0,kp0]=GA_iys(Mz, D, T, Vw)
%Geo-Acoustics model
%clear all
% Mz=inputdlg('mean grain size');Mz=str2double(Mz);
% D=inputdlg('water depth');D=str2double(D);
% T=inputdlg('travel time in sediment');T=str2double(T);
% Vw=inputdlg('bottom velocity');Vw=str2double(Vw);
depth = D; % Add
if Mz <= 4.5 %CASE I less than 4.5phi silty sand(4.35phi)
    %糷の┏借场だ羘硉, VpZ_1
    R=1.285-0.0601*Mz+2.83e-3*Mz.^2;
    Vp0=Vw*R;
    clear D Vw R
    %辫︽縩だ猭―℉縩糷瞏, H
    Z=[0.0001:0.0001:T];
    K=Vp0/0.05^0.015;
    VpZ=K.*Z.^0.015;
    H=trapz(Z,VpZ);
    H=floor(H);
    Z=1:1:H;
    K=Vp0/0.05^0.015;
    VpZ_1=K.*Z.^0.015;
    %   plot(VpZ_1,1:H); axis ij
    clear K T VpZ Z
    
    %┏借场だ癐搭玒计, kpZ_1
    if Mz<=2.6
        kp0=0.4556+0.0245*Mz; %%%э场だ(2014/09/02)
    else %2.6<Mz<=4.5
        kp0=0.1978+0.1245*Mz;
    end
    z_a=1:200;
    [m,n]=size(z_a);kpZ_1a=zeros(m,n);
    indx=find((z_a));
    kpZ_1a(indx)=kp0*z_a(indx).^(-1/6);
    z_b=1:H-200;
    [m,n]=size(z_b);kpZ_1b=zeros(m,n);
    indx=find((z_b));
    kpZ_1b(indx)=kpZ_1a(200)-1.4e-4*z_b(indx)+0.03;
    kpZ_1=[kpZ_1a kpZ_1b];
    %   plot(kpZ_1,1:H); axis ij
    clear indx kpZ_1a kpZ_1b m n z_a z_b ans
    
    %┏借场だ盞, rhoZ_1
    if H<=500
        for i=1:H
            rho_1_a(i)=1.135*VpZ_1(i)/1000-0.19;
        end
        rho0=[rho_1_a(1)];
        rhoZ_1=[rho_1_a];
    else %H>500
        for i=1:500
            for j=1:H-500
                rho_1_a(i)=1.135*VpZ_1(i)/1000-0.19;
                rho_1_b(j)=0.917+0.744*VpZ_1(j)/1000-0.08*(VpZ_1(j)/1000)^2;
            end
        end
        rho0=[rho_1_a(1)];
        rhoZ_1=[rho_1_a rho_1_b];
    end
    clear i j rho_1_a rho_1_b;
    %   plot(rhoZ_1,1:H); axis ij
    %   save silty sand VpZ_1 kpZ_1 rhoZ_1 z
    fid=fopen('GA.out','w');
    for i=1:50:H
        fprintf(fid,'%6.2f %6.2f %6.2f %6.2f\n',i-1,VpZ_1(i),kpZ_1(i),rhoZ_1(i));%H,VpZ_1,kpZ_1,rhoZ_1
    end
    fclose(fid);
%     %% Add
%     cb = interp1([0:50:H], VpZ_1(1:50:H),depth,'linear');
%     thob = interp1([0:50:H], rhoZ_1(1:50:H),depth,'linear');
%     alphab = interp1([0:50:H], kpZ_1(1:50:H),depth,'linear');
else %CASE II more than 4.5phi sandy silt(5.02phi)
    %糷の┏借场だ羘硉, VpZ_2
    R=1.305-0.0601*Mz+2.83e-3*Mz.^2;
    Vp0=Vw*R;
    clear Vw R
    %辫︽縩だ猭―℉縩糷瞏, H
    %狦笵T―℉縩糷瞏э把计Z场だ
    Z=[0.0001:0.0001:T];
    %model II 惠瑅吏挂
    if D<=400 %ocean environment:continental terrace(0m-400m), include continental shelf and slope
        VpZ=Vp0+0.710.*Z-0.085*10^-4.*Z.^2;
    elseif D<=900 %ocean environment:continental rise (400m-900m), include upper rise and lower rise
        VpZ=Vp0+0.828.*Z-1.38*10^-4.*Z.^2;
    else %D>900, ocean enviroment:deep sea and abyssal plain(900m~~)
        VpZ=Vp0+1.227.*Z-0.473*10^-4.*Z.^2;
    end
    H=trapz(Z,VpZ);
    H=floor(H);
    Z=1:1:H;
    if D<=400
        VpZ_2=Vp0+0.710.*Z-0.085*10^-4.*Z.^2;
    elseif D<=900
        VpZ_2=Vp0+0.828.*Z-1.38*10^-4.*Z.^2;
    else %D>900
        VpZ_2=Vp0+1.227.*Z-0.473*10^-4.*Z.^2;
    end
    %   plot(VpZ_2,1:H,'r'); axis ij
    clear K T VpZ Z D
    
    %┏借场だ癐搭玒计, kpZ_2
    if Mz<=6.0
        kp0=8.0399-2.5228*Mz+0.20098*Mz^2; %%%э场だ(2014/09/02)
    else %Mz<=9.5
        kp0=0.9431-0.2041*Mz+0.0117*Mz^2; %%%э场だ(2014/09/02)
    end
    z_a=1:200;
    [m,n]=size(z_a);kpZ_2a=zeros(m,n);
    indx=find((z_a));
    kpZ_2a(indx)=kp0+2.5e-4*z_a(indx);
    z_b=1:H-200;
    [m,n]=size(z_b);kpZ_2b=zeros(m,n);
    indx=find((z_b));
    kpZ_2b(indx)=kpZ_2a(200)-1.4e-4*z_b(indx)+0.03;
    kpZ_2=[kpZ_2a kpZ_2b];
    %   plot(kpZ_2,1:H); axis ij
    clear indx kpZ_2a kpZ_2b m n z_a z_b ans
    
    %┏借场だ盞, rhoZ_2
    if H<=500
        for i=1:H
            rho_2_a(i)=1.135*VpZ_2(i)/1000-0.19;
        end
        rho0=[rho_2_a(1)];
        rhoZ_2=[rho_2_a];
    else %H>500
        for i=1:500
            for j=1:H-500
                rho_2_a(i)=1.135*VpZ_2(i)/1000-0.19;
                rho_2_b(j)=0.917+0.744*VpZ_2(j)/1000-0.08*(VpZ_2(j)/1000)^2;
            end
        end
        rho0=[rho_2_a(1)];
        rhoZ_2=[rho_2_a rho_2_b];
    end
    clear i j rho_2_a rho_2_b
    %   plot(rhoZ_2,1:H); axis ij
    %   save silty sand VpZ_2 kpZ_2 rhoZ_2 z
    
    %%
    fid=fopen('GA.out','w');
    for i=1:50:H
        fprintf(fid,'%6.2f %6.2f %6.2f %6.2f\n',i-1,VpZ_2(i),kpZ_2(i),rhoZ_2(i));%H,VpZ_2,kpZ_2,rhoZ_2
    end
    fclose(fid);
%     %% Add
%     cb = interp1([0:50:H], VpZ_2(1:50:H),depth,'linear');
%     thob = interp1([0:50:H], rhoZ_2(1:50:H),depth,'linear');
%     alphab = interp1([0:50:H], kpZ_2(1:50:H),depth,'linear');
end
end
% subplot(131); plot(VpZ_2,1:H); axis ij; grid on; ylabel('depth(m)'); xlabel('velocity(m/s)')
% subplot(132); plot(kpZ_2,1:H); axis ij; grid on; title('clayey silt '); xlabel('attenuation coefficient(dB/m/khz)')
% subplot(133); plot(rhoZ_2,1:H); axis ij; grid on; xlabel('density(g/cm3)')