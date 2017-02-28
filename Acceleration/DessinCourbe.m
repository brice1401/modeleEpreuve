%Ceux pour l'accélération
figure
subplot(2, 1, 1)
plot(AccLong)
title('Acceleration longitudinale')
ylabel('Acceleration')
xlabel('Temps (s)')

subplot(2, 1, 2)
plot( AccLat)
title('Acceleration laterale')
xlabel('Temps (s)')
%%
%Ceux pour les charges
figure
subplot(2, 2, 1)
plot(ChargeAvantGauche)
title('Charge Roue Avant Gauche')
ylabel('Charge (N)')
xlabel('Temps (s)')

subplot(2, 2, 2)
plot( ChargeAvantDroit)
title('Charge Roue Avant Droite')
ylabel('Charge (N)')
xlabel('Temps (s)')

subplot(2, 2, 3)
plot( ChargeArrGauche)
title('Charge Roue Arriere Gauche')
ylabel('Charge (N)')
xlabel('Temps (s)')

subplot(2, 2, 4)
plot( ChargeArrDroit)
title('Charge Roue Arriere Droite')
ylabel('Charge (N)')
xlabel('Temps (s)')


%%
%Graphiques de la vitesse et de la distance parcouru en longitudinale
figure
subplot(2, 1, 1)
plot(Vitesse)
title('Vitesse Longitudinale')
xlabel('Temps (s)')
ylabel({'Vitesse'; '(m.s^-1)'})

subplot(2, 1, 2)
plot(Distance)
title('distance parcouru longitudalement :')
xlabel('Temps (s)')
ylabel('Distance (m)')