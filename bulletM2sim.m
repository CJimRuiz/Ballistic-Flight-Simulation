% =========================================================================
% .30-06 Caliber, Ball, M2 Bullet 6-DOF Kinematic Simulation & Visualization
% Reproducing the behavior from "bullet.avi"
% =========================================================================

clear; clc; close all;
%% 1. Define Bullet & Simulation Parameters for .30-06 Springfield, specifically, Ball, M2 

%Data sourced from TM 43-0001-27, Page 5-9

% Ballistic & Physical Specs

v0_fps = 2740;                  % Velocity 2740 fps, 78 ft / 23.77 m from muzzle
v0 = v0_fps * 0.3048;           % converted to m/s

twist_rate_in = 10;             % 1 turn in 10 inches (standard M1 Garand / .30-06 twist)
twist_m = twist_rate_in * 0.0254; % Convert twist to meters (0.254 m)

spin_rps = v0 / twist_m;        % Revolutions per second ~ 3228 RPS
rpm = spin_rps * 60;            % Spin rate ~ 193,700 RPM
spin_rate = rpm * (2*pi/60);    % Convert to radians per second

g = 9.81;                       % Gravitational force
m = 0.00985;                    % Mass in kg for 150-152 grain

% Simulation time 

dt = 0.00005;                   % Time step
t_end = 0.005;                  % Simulation duration
time = 0:dt:t_end;

%% Bullet dimensions of .30-60 Springfield, WWII caliber, M2 Ball, 150-152 gr flat base

radius   = 0.00391;             % 3.91 mm radius (.308 in groove diameter)
len_body = 0.0137;              % 13.7 mm cylindrical bearing surface / shank
len_nose = 0.0140;              % 14.0 mm 7-caliber tangent ogive (27.7 mm total bullet length)

%% 2. Generate 3D Bullet Geometry

% Create cylinder (body)
[Z_cyl, Y_cyl, X_cyl] = cylinder(radius, 30);
X_cyl = X_cyl * len_body;

% Create cone (nose)
[Z_nose, Y_nose, X_nose] = cylinder(linspace(radius, 0, 30), 30);
X_nose = X_nose * len_nose + len_body;

% Combine matrices
X_b = [X_cyl; X_nose] - (len_body/2); % Shift so CG is roughly at origin
Y_b = [Y_cyl; Y_nose];
Z_b = [Z_cyl; Z_nose];

%% 3. Setup the 3D Plot Environment
fig = figure('Name', 'Bullet Simulation', 'Color', [0.8 0.8 0.8], ...
    'Position', [100, 100, 800, 600]);
ax = axes('Parent', fig);

% We use hgtransform to move the 3D object without redrawing it which is much faster
bullet_transform = hgtransform('Parent', ax);

% Plot the surface and attach it to the transform object
surf(X_b, Y_b, Z_b, 'Parent', bullet_transform, 'EdgeColor', '#444444');
colormap(jet); % Matches the rainbow heat map from the video

% Format the axes to match the video style
grid on; view(3); axis equal;

% Color of axis numbers (tick values) and axis lines!
ax.XColor = 'red';  % RGB vector for orange
ax.YColor = 'yellow';     % Built-in color name
ax.ZColor = 'blue';       % blue Z axis color

% Color for labels and title!
xlabel('X / Distance (m)', 'FontWeight', 'bold', 'Color', 'red'); 
ylabel('Y / Drift (m)', 'FontWeight', 'bold', 'Color', 'yellow'); 
zlabel('Z / Height (m)', 'FontWeight', 'bold');
title('.30-06 Springfield - ~194k RPM Spin with Pitch Disturbance', 'Color', 'black');

% Set viewing limits
xlim([-0.05, 4]); 
ylim([-0.05, 0.05]); 
zlim([-0.02, 0.1]);

%% 4. Run the Animation Loop & Save GIF

gif_filename = 'bullet_animation.gif';
frame_delay = 0.03;  % ~33 FPS playback speed
frame_skip = 2;      % Skip every N frames to keep file size reasonable

first_frame = true;

for i = 1:frame_skip:length(time)
    t = time(i);

    % --- Calculate Position ---
    x = v0 * t;                     % Forward travel
    y = 0.01 * t;                   % Slight lateral drift
    z = (0.08 / t_end) * t;         % Climbs to 80mm as stated in the video

    % --- Calculate Orientation (Attitude) ---

    roll = spin_rate * t;           % Fast axial spin

    % Epicyclic swerve (pitch and yaw oscillation due to barrel exit)
    nutation_freq = 1500;           % High frequency wobble
    pitch = 0.08 * sin(nutation_freq * t); 
    yaw   = 0.08 * cos(nutation_freq * t);

    % --- Create Transformation Matrices ---

    % 1. Translate the bullet to its current x, y, z position
    M_trans = makehgtform('translate', [x, y, z]);

    % 2. Rotate the bullet around its axes
    M_rotx  = makehgtform('xrotate', roll);
    M_roty  = makehgtform('yrotate', pitch);
    M_rotz  = makehgtform('zrotate', yaw);

    % --- Apply Transformations ---
    
    % Matrix multiplication order matters: scale -> rotate -> translate
    bullet_transform.Matrix = M_trans * M_rotz * M_roty * M_rotx;

    % Move the camera to follow the bullet
    xlim([x - 0.1, x + 0.3]);

    % Force MATLAB to draw the current frame
    drawnow;

    % --- Capture and write frame to GIF ---
    frame = getframe(fig);
    im = frame2im(frame);
    [imind, cm] = rgb2ind(im, 256);

    if first_frame
        imwrite(imind, cm, gif_filename, 'gif', 'Loopcount', inf, 'DelayTime', frame_delay);
        first_frame = false;
    else
        imwrite(imind, cm, gif_filename, 'gif', 'WriteMode', 'append', 'DelayTime', frame_delay);
    end
end

fprintf('GIF saved as: %s\n', fullfile(pwd, gif_filename));