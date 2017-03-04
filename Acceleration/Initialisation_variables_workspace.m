clear all
close all


%Param�tres g�om�triques du v�hicule en mm

h_v = 0.3; %hauteur du centre de gravit� du v�hicule
h_p = 0.3; %hauteur du centre de gravit� du pilote
e = 1.2; %empattement
b = 0.5; %distance selon x entre le centre de gravit� et le centre des roues arriere
v = 1.2; %voie

%Param�tre v�hicule
mveh = 215; %masse de la voiture
mpilote = 70; %Masse du pilote
mtot = mveh + mpilote; %masse de l'ensemble
m = mtot;
g = 9.81;
h = (mpilote*h_p + mveh*h_v)/m; %hauteur du centre de gravit�
D_roue = 0.53; % Diametre exterieur de la roue (m)
R = D_roue/2; %Rayon de la roue

coeff_roul = 0.01; % Coefficient de resistance au roulement du pneu (delta en m)

J_rot = 0.111; % Inertie d'une roue �quip�e (kg.m�)
J_trans = m*R^2; % Inertie equivalente des masses en translation (kg.m�)
J_eq = J_trans + 4*J_rot; % Inertie totale (kg.m�)

%Moteur
%Courbe moteur
C_mot = [0,45.126,51.01200000000001,52.974000000000004,51.01200000000001,48.069,49.050000000000004,51.01200000000001,56.898,58.86,58.86,57.879000000000005,56.898,54.936,51.993,48.069,44.145,40.221,36.297000000000004,32.373];

%R�gime correspondant
regime = [0, 4500:500:13500];


%Param�tre boite de vitesse :
rap_pri = 36/76;
rap(1) = 12/33;
rap(2) = 16/32;
rap(3) = 18/30;
rap(4) = 18/26;
rap(5) = 23/30;
rap(6) = 24/29;
rap_couronne = 13/45;

%Donnees pour le passage des vitesses
%les vitesses sont en km/h
v1 = 62.7;
v2 = 80.5;
v3 = 95;
v4 = 107.9;
v5 = 118.3;

v_passage = [0, v1, v2, v3, v4, v5]/3.6; %vitesse en m/s
rapport = [1, 2, 3, 4, 5, 6];

%Parametre aerodynamique
rho = 1.2; %masse volumique de l'air en kg/m3
Cx = 0.7; %coeff de train�e
S = 1; %surface de r�f�rence (m2)

%Param�tre initiaux de la simulation
vitesse_initiale = 0;


%Lancement de la simulation :
sim('Accel_model');


%Cr�ation des graphiques

run('DessinCourbe.m');
