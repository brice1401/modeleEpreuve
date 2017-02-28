%=== Code Matlab ===

%Accélération

    % Le script suivant permet de simuler une acceleration sur une distance
    % donnee. De nombreuses ameliorations peuvent etre apportees par la suite.
    % La courbe de couple moteur doit etre la plus complete possible pour de
    % meilleurs resultats
    % Ce script est utile pour voir l'influence des differents parametres sur
    % le temps de l'acceleration

    %% Hypotheses
    % Le pneu est indeformable
    % Le coeff d'adherence des pneus est constant
    % Le coeff de résistance au roulement est constant
    % Le glissement est considere nul
    % La voiture n'a pas de suspensions
    % Le transfert de charge est instantane
    % Les pertes dans la transmission sont proportionnelles au couple
    % Le temps de passage de rapport ne depend pas des rapports concernes
    % Les rapport passent sans debrayer
    % L'aerodynamique (appui et trainee) est neglige

    %%
    clear all
    close all

    %% Parametres
    % Epreuve et pilotage
    D_tot = 75; % Longueur de la piste (m)
    r_pat = 9000; % Regime de patinage de l'embrayage (tr/min)
    m_p = 50; % Masse du pilote (kg)
    h_g_p = 0.3; % Hauteur du centre de gravite du pilote (m)
    k = 1; % Rapport engage au depart
    k_max = 3; % Rapport maximum
    % Base roulante
    m_v = 235; % Masse du vehicule (kg)
    h_g_v = 0.3; % Hauteur du centre de gravite de la voiture (m)
    emp = 1.585; % Empattement (m)
    rep = 0.5; % Masse sur l'essieu arrière en statique (%)
    D_roue = 0.53; % Diametre exterieur de la roue (m)
    J_rot = 0; % Inertie equivalente des masses en rotation (kg.m²)
    % Pneumatiques
    coeff_adh = 1.5; % Coefficient d'adherence longitudinal du pneu
    coeff_roul = 0.01; % Coefficient de resistance au roulement du pneu
    % Moteur
    rmot = [0 4500:500:13500]; % Regime moteur (tr/min)
    cmot = [0 4.6 5.2 5.4 5.2 4.9 5 5.2 5.8 6 6 5.9 5.8 5.6 5.3 4.9 4.5 4.1 3.7 3.3]; % Couple moteur (m.kg)
    r_rupteur = 14000; % Regime de rupteur (tr/min)
    t_pas = 0.09; % Temps de passage de rapport (s)
    % Transmission
    k_p = 36/76; % Rapport primaire
    K(1) = 12/33; % Rapport de 1ere
    K(2) = 16/32; % Rapport de 2eme
    K(3) = 18/30; % Rapport de 3eme
    K(4) = 18/26; % Rapport de 4eme
    K(5) = 23/30; % Rapport de 5eme
    K(6) = 24/29; % Rapport de 6eme
    k_f = 13/45; % Rapport final
    pertes = 0.95; % Coefficient de pertes de couple dans la transmission
    %%
    % Vitesses (m/s)
    for i = 1:6
        vitesse(:,i) = rmot*k_p*K(i)*k_f*D_roue*3.14/60;
    end
    % Couples aux roues (m.kg)
    for i = 1:6
        couple(:,i) = cmot*pertes/(k_p*K(i)*k_f);
    end
    g = 9.81; % Pesanteur (m/s²)
    m = m_v + m_p; % Masse totale (kg)
    h_g = (m_v*h_g_v+m_p*h_g_p)/m; % Hauteur du centre de gravite (m)
    b = coeff_roul*2/D_roue; % Decalage du point d'appui (m)
    c_roul = m*g*b; % Resistance au roulement (N.m)
    % Inertie
    J_trans = m*D_roue*D_roue/4; % Inertie equivalente des masses en translation (kg.m²)
    J_eq = J_trans + J_rot; % Inertie totale (kg.m²)
    %% Paramètres simulation
    pas = 0.01; % Pas de simulation (s)
    n = t_pas/pas; % Nombre de pas necessaire au passage de rapport
    % Initialisation
    d = 0; % distance parcourue
    r = r_pat; % regime moteur au depart
    v = 0; % vitesse du vehicule
    t = -pas; % temps
    j = 0; % Numero du point de fonctionnement du moteur
    T = [0]; % Temps
    V = [0]; % Vitesse
    A = [0]; % Acceleration en g
    R = [r_pat]; % Regime
    Ke = [k]; % Rapport engage
    C = [0]; % Couple
    D = [0]; % Distance
    R_pas = []; % Regimes de passage de rapport
    T_pas = [];
    E = [1]; % Embrayage 1=debraye, 0=embraye
    Adh = [1]; % Risque de patinage des pneus
    u = n;
    Ch_ar = [rep*m*g];
    %% Simulation
    while d < D_tot
        t = t+pas;
        T = [T t];
        Ke = [Ke k]; % Memoire du rapport engage
        r = v/(k_p*K(k)*k_f*D_roue*3.14/60); % Calcul du regime moteur
        % Prise en compte du patinage de l'embrayage
        if k == 1
            if r < r_pat
                E = [E, 1]; % Patinage
            else E = [E,0]; % Pas de patinage
            end
        r = max(r,r_pat);
        else E = [E,0];
        end
        R = [R r];
        % Acceleration
        if u < n || r > r_rupteur % Changement de rapport
            a=0; % Acceleration nulle si changement de rapport
            C = [C, 0]; % Memoire couple aux roues
            A = [A,0]; % Memoire acceleration
            Adh = [Adh, 0]; % Pas de risque de patinage des pneus
            Ch_ar =[Ch_ar rep*m*g];
        else
            % Recherche du point de fonctionnement le plus proche dans les points connus
            r_dif = max(rmot);
            for i = 1:size(rmot,2)
                if abs(rmot(i)-r)<r_dif
                    r_dif = abs(rmot(i)-r);
                    j_k=i;
                end
            end
            c_k = couple(j_k,k); % Couple a la roue au rapport engage (m.kg)
            a_ang = (c_k*10-c_roul)/J_eq; % Acceleration angulaire des roues arrieres
            C_ar = rep*m*g+m*a_ang*(D_roue/2)*h_g/emp; % Charge sur l'essieu arrière avec prise en compte du transfert de masse
            if C_ar > m*g % Cas ou les roues avant se soulevent
            C_ar = m*g;
            end
            c_trans_ar = coeff_adh*C_ar*D_roue/2; % Couple maximum transmissible
            if c_k > c_trans_ar/10 % Risque de patinage des pneus
                Adh = [Adh,1];
                c_k = c_trans_ar/10; % Prise en compte de la limite d'adherence des pneus
                a_ang = (c_k*10-c_roul)/J_eq; % Acceleration angulaire des roues arrieres
                C_ar = rep*m*g+m*a_ang*(D_roue/2)*h_g/emp; % Charge sur l'essieu arrière avec prise en compte du transfert de masse
            else Adh = [Adh, 0];
            end
            C = [C, c_k]; % Memoire du couple aux roues
            Ch_ar =[Ch_ar C_ar];
            a = a_ang*D_roue/2; % Acceleration du vehicule en m/s²
            A = [A,a/10]; % Memoire acceleration en g
        end
        v = v + a*pas; % Vitesse du vehicule
        V = [V v]; % Memoire de la vitesse
        d = d + v*pas; % Distance parcourue
        D = [D, d]; % Memoire de la distance
        r = v/(k_p*K(k)*k_f*D_roue*3.14/60); % Calcul du regime moteur
        % Changement de rapport
        % Changement au rupteur
        if r > r_rupteur && u >n && k<6 && k<k_max
            k = k+1;
            u=0;
            R_pas = [R_pas, r_rupteur];
            T_pas = [T_pas, t];
            % Changement de rapport pour optimiser le couple
        elseif k<k_max && u >n
            % Determination du regime le plus proche dans les points de fonctionnement connus
            r_dif = max(rmot);
            for i = 1:size(rmot,2)
                if abs(rmot(i)-r)<r_dif
                    r_dif = abs(rmot(i)-r);
                    j_k=i;
                end
            end
            c_k = couple(j_k,k); % Couple a la roue au rapport engage
            r_sup = v/(k_p*K(k+1)*k_f*D_roue*3.14/60); % Calcul du regime moteur au rapport superieur
            r_dif = max(rmot);
            for i = 1:size(rmot,2)
                if abs(rmot(i)-r_sup)<r_dif
                    r_dif = abs(rmot(i)-r_sup);
                    j_ksup=i;
                end
            end
            c_ksup = couple(j_ksup,k+1); % couple a la roue au rapport superieur
            if c_ksup > c_k && k<6 % Condition de changement de rapport
                k = k+1;
                u=0;
                R_pas = [R_pas, r];
                T_pas = [T_pas, t];
            end
        end
        u = u+1;
    end
    %% Principaux resultats
    disp('Temps (s) :')
    disp(t)
    disp('Vitesse max (km/h) :')
    disp(max(V)*3.6)
    disp('Acceleration max (g) :')
    disp(max(A))
    disp('Regimes de passage de rapport (tr/min) :')
    disp(round(R_pas))
    if max(Ch_ar) == m*g
        disp('Wheeliiiinnngg ! :p')
    end
    disp('---------------------------------------------------------')
    %% Courbe moteur
    figure('Name','Caracteristique moteur'),
    [fAx,fLine1,fLine2] = plotyy(rmot/1000,cmot,rmot/1000,(rmot*3.14/30).*(cmot*10)/1000*1.34);
    xlabel('Regime (x 1000 tr/min)');
    set(fAx,'xlim',[0 r_rupteur/1000],'xtick',0:1:r_rupteur/1000)
    set(fAx(1),'ylim',[0 14],'ytick',0:1:7)
    ylabel(fAx(1),'Couple (m.kg)');
    set(fAx(2),'ylim',[-40 90],'ytick',0:10:90)
    ylabel(fAx(2),'Puissance (ch)');
    title('Caracteristique moteur');
    %% Courbes en fonction du temps
    figure('Name','Résultats en fonction du temps')
    subplot(311),plot(T,R);
    xlabel('Temps');
    xlim([0 t]);
    ylim([6000 13000]);
    ylabel('Regime moteur (tr/min)');
    subplot(312),plot(T,A);
    xlabel('Temps');
    xlim([0 t]);
    ylim([0 max(A)+0.2]);
    ylabel('Acceleration (g)');
    subplot(313),plot(T,V*3.6);
    xlabel('Temps');
    xlim([0 t]);
    ylim([0 120]);
    ylabel('Vitesse (km/h)');
    figure('Name','Résultats en fonction du temps')
    subplot(211),[jAx,jLine1,jLine2] = plotyy(T,R,T,C);
    xlabel('Temps (s)');
    set(jAx,'xlim',[0 t],'xtick',0:0.5:t);
    set(jAx(1),'ytick',6000:2000:14000);
    set(jAx(1),'ylim',[6000 14000],'yticklabel',num2str(get(jAx(1),'YTick')','%d'));
    set(jAx(2),'ylim',[0 120],'ytick',0:20:120);
    ylabel(jAx(1),'Regime moteur (tr/min)');
    ylabel(jAx(2),'Couple aux roues (m.kg)');
    subplot(212),[hAx,hLine1,hLine2] = plotyy(T,Ke,T,E);
    xlabel('Temps (s)');
    set(hAx,'xlim',[0 t],'xtick',0:0.5:t);
    set(hAx(1),'ylim',[0 max(Ke)+1],'ytick',0:1:5);
    ylabel(hAx(1), 'Rapport engage');
    set(hAx(2),'ylim',[0 2],'ytick',0:1:1);
    ylabel(hAx(2), 'Embrayage');
    figure('Name','Résultats en fonction du temps')
    subplot(211),[gAx,gLine1,gLine2] = plotyy(T,A,T,Adh);
    xlabel('Temps');
    set(gAx,'xlim',[0 t],'xtick',0:0.5:t);
    set(gAx(1),'ylim',[0 1.5],'ytick',0:0.2:1.5);
    ylabel(gAx(1),'Acceleration (g)');
    set(gAx(2),'ylim',[0 2],'ytick',0:1:1);
    ylabel(gAx(2), 'Risque de patinage des pneus');
    subplot(212),[hAx,hLine1,hLine2] = plotyy(T,Ch_ar,T,m*g-Ch_ar);
    xlabel('Temps(s)');
    set(hAx,'xlim',[0 t],'xtick',0:0.5:t)
    set(hAx(1),'ylim',[min(m*g-Ch_ar)-100 max(Ch_ar)+100])
    ylabel(hAx(1),'Charge sur les pneus arriere (N)');
    set(hAx(2),'ylim',[min(m*g-Ch_ar)-100 max(Ch_ar)+100])
    ylabel(hAx(2),'Charge sur les pneus avant (N)');
    %% Courbes en fonction de la distance
    figure('Name','Résultats en fonction de la distance')
    subplot(311),plot(D,R);
    xlabel('Distance');
    xlim([0 D_tot]);
    ylim([6000 13000]);
    ylabel('Regime moteur (tr/min)');
    subplot(312),plot(D,A);
    xlabel('Distance');
    xlim([0 D_tot]);
    ylim([0 1.5]);
    ylabel('Acceleration (g)');
    subplot(313),plot(D,V*3.6);
    xlabel('Distance');
    xlim([0 D_tot]);
    ylim([0 120]);
    ylabel('Vitesse (km/h)');
    figure('Name','Résultats en fonction de la distance')
    subplot(211),[jAx,jLine1,jLine2] = plotyy(D,R,D,C);
    xlabel('Temps (s)');
    set(jAx,'xlim',[0 D_tot],'xtick',0:5:D_tot);
    set(jAx(1),'ytick',6000:2000:14000);
    set(jAx(1),'ylim',[6000 14000],'yticklabel',num2str(get(jAx(1),'YTick')','%d'));
    set(jAx(2),'ylim',[0 120],'ytick',0:20:120);
    ylabel(jAx(1),'Regime moteur (tr/min)');
    ylabel(jAx(2),'Couple aux roues (m.kg)');
    subplot(212),[hAx,hLine1,hLine2] = plotyy(D,Ke,D,E);
    xlabel('Distance (m)');
    set(hAx,'xlim',[0 D_tot],'xtick',0:5:D_tot);
    set(hAx(1),'ylim',[0 max(Ke)+1],'ytick',0:1:5);
    ylabel(hAx(1), 'Rapport engage');
    set(hAx(2),'ylim',[0 2],'ytick',0:1:1);
    ylabel(hAx(2), 'Embrayage');
    figure('Name','Résultats en fonction de la distance')
    subplot(211),[gAx,gLine1,gLine2] = plotyy(D,A,D,Adh);
    xlabel('Distance (m)');
    set(gAx,'xlim',[0 D_tot],'xtick',0:5:D_tot);
    set(gAx(1),'ylim',[0 1.5],'ytick',0:0.2:1.5);
    ylabel(gAx(1),'Acceleration (g)');
    set(gAx(2),'ylim',[0 2],'ytick',0:1:1);
    ylabel(gAx(2), 'Risque de patinage des pneus');
    subplot(212),[hAx,hLine1,hLine2] = plotyy(D,Ch_ar,D,m*g-Ch_ar);
    xlabel('Distance (m)');
    set(hAx,'xlim',[0 D_tot],'xtick',0:5:D_tot)
    set(hAx(1),'ylim',[min(m*g-Ch_ar)-100 max(Ch_ar)+100])
    ylabel(hAx(1),'Charge sur les pneus arriere (N)');
    set(hAx(2),'ylim',[min(m*g-Ch_ar)-100 max(Ch_ar)+100])
    ylabel(hAx(2),'Charge sur les pneus avant (N)');