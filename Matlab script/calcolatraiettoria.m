function plot_field_B(I,R,rho)
    % Plot 3d del campo magnetico
    % Input:
    % I - intensità di corrente
    % R - raggio della spira
    % rho - spessore del toro

    % Crea una meshgrid di punti in cui valutare il campo
    [x,y,z] = meshgrid(-2*R:2:2*R,-2*R:2:2*R,-2*R:2:2*R);
    nPoints = numel(x);
    
    % Inizializza i vettori dei risultati
    Bx = zeros(nPoints, 1);
    By = zeros(nPoints, 1);
    Bz = zeros(nPoints, 1);

    % Vettorializza le coordinate
    xVec = x(:);
    yVec = y(:);
    zVec = z(:);

    % for loop
    parfor i = 1:nPoints
        r = [xVec(i), yVec(i), zVec(i)];
        [Bx(i), By(i), Bz(i)] = calcola_campo_B(R, I, r, rho);
    end

    % Ricostruisce la forma matriciale per il plot
    Bx = reshape(Bx, size(x));
    By = reshape(By, size(y));
    Bz = reshape(Bz, size(z));

    % Plot
    figure;
    quiver3(x, y, z, Bx, By, Bz, 0.5, 'Color', 'r');
    axis equal;
    title("Gradiente del campo magnetico della spira.", ['I = ', int2str(I), '; ', 'R = ', num2str(R), '.']);
    light;

    % Impostiamo una scala per la trasparenza (AlphaData)
    %max_magnitude = max(magnitude(:));
    %min_magnitude = min(magnitude(:));
    
    % Calcolare la trasparenza: più alta è la magnitudine, meno trasparente è il punto
    %alpha_values = (magnitude - min_magnitude) / (max_magnitude - min_magnitude); % Normalizzare tra 0 e 1
    
    % Mostra i punti con il colore e la trasparenza basati sulla magnitudine
    %figure;
    %scatter3(x(:), y(:), z(:), 5, magnitude(:), 'filled', 'MarkerFaceAlpha', 'flat', 'AlphaData', alpha_values(:));
    
    % Usa la colormap jet e aggiungi una barra dei colori
    %colormap jet;
    %colorbar; % Barra dei colori che mostra la scala delle magnitudini
    %axis equal;
    %grid on
    %title("Intensità del campo magnetico della spira.");
    
    figure;
    [startX,startY,startZ] = meshgrid(-20:20:20,-20:10:20,-10:5:10);
    verts = stream3(x,y,z,Bx,By,Bz,startX,startY,startZ);
    lineobj = streamline(verts);
    for i = 1:length(lineobj)
        lineobj(i).Color = 'b';
        lineobj(i).LineWidth = 1;
    end
    view(3);
    hold on;
    
    % Traccia il toro centrato in 0 di raggio R
    [u,v] = meshgrid(linspace(0, 2*pi, 1000),linspace(0, 2*pi, 1000)); % Angolo da 0 a 2pi
    x_torus = (R+rho*cos(u)).*cos(v); % Componente x del toro
    y_torus = (R+rho*cos(u)).*sin(v); % Componente y del toro
    z_torus = rho*sin(u); % Componente z del toro
    surf(x_torus, y_torus, z_torus, 'EdgeColor', 'none');
    colormap jet; % Mappa di colori
    
    grid off;
    axis tight;
    title("Linee di flusso del campo B.");
    light;
end



function plot_traiettoria_B(r,R,rho,m,q,v0,I)
  % Plot della traiettoria e del toro
  % Input:
  % r = array 3xN contenente la traiettoria
  % R = raggio del toro
  % rho = spessore del toro
  % m = massa della particella
  % q = carica della particella
  % v0 = velocità iniziale
  % I = intensità della corrente nel toro

  % Plot della traiettoria
  figure; clf;
  plot3(r(:,1), r(:,2), r(:,3), 'b', 'LineWidth', 2);
  hold off;
  hold on;
  plot3(r(1,1), r(1,2), r(1,3), 'go', 'MarkerSize', 8, 'MarkerFaceColor', 'g'); % Punto iniziale
  plot3(r(end,1), r(end,2), r(end,3), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r'); % Punto finale
  hold on;

  % Traccia il toro centrato in 0 di raggio R
  [u,v] = meshgrid(linspace(0, 2*pi, 1000),linspace(0, 2*pi, 1000)); % Angolo da 0 a 2pi
  x_torus = (R+rho*cos(u)).*cos(v); % Componente x del toro
  y_torus = (R+rho*cos(u)).*sin(v); % Componente y del toro
  z_torus = rho*sin(u); % Componente z del toro
  surf(x_torus, y_torus, z_torus, 'EdgeColor', 'none');
  colormap jet; % Mappa di colori

  xlabel('x'); ylabel('y'); zlabel('z');
  v0_norm = norm(v0); % Modulo della velocità
  E_k = m*v0_norm^2/2; % Energia cinetica
  E_k = 6.242e15*E_k; % Conversione in keV
  title('Traiettoria della particella nel campo magnetico', ...
      ['I = ' ,int2str(I), '; ', 'm = ', num2str(m), 'kg; ','q = ',num2str(q),'C; ','v0 = ', num2str(v0_norm,'%e'), 'm/s; ', 'E_k = ', num2str(E_k), 'keV.']);
  grid on; 
  axis equal;
  legend({'Traiettoria', 'Inizio', 'Fine', 'Target'}, 'Location', 'Best');
  light; %lightning phong;
end

R = 20;
rho = 1.5;
r0 = [0,80,0];
v0 = [0,-1e5,0];
%m = 55.85*1.66e-27; % Massa nucleo Fe26
%m = 9.11e-31; % Massa elettrone
m = 1.67e-27; % Massa protone
q = 1.6e-19;
I = 5e5;
T_max = 1e-3;
dt = 1e-7;
[r,shield] = calcola_traiettoria_B(r0, v0, q, m, R, rho, I, dt, T_max);
plot_traiettoria_B(r,R,rho,m,q,v0,I);
%plot_field_B(I,R,rho);