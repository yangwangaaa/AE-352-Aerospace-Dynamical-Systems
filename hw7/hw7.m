function hw7

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% CAN CHANGE
%

% - This line says your name.
params.teamname = 'My Team (Steve Macenski & Chris Lorenz)';
% - This line says the file to record your actions.
params.action_filename = 'action.mat';
% - This line says the file to record your movie.
params.movie_filename = 'movie.mp4';
% - This line says the file to record your snapshot.
params.snapshot_filename = 'snapshot.pdf';
% - This line says whether or not you want to record a movie --- change it
%   from "false" to "true" and you will record a movie. Note that you must
%   have already recorded actions, before making a movie!
params.makemovie = false;
% - This line says whether or not you want to take a snapshot --- change it
%   from "false" to "true" and you will create a PDF of the figure after
%   the simulation is over.
params.makesnapshot = false;

% The keyboard interface is as follows:
%
%   'q'         causes the simulation to quit (gracefully, saving the
%               actions, the movie, and/or the snapshot)
%
% The mouse interface allows you to specify the motor torque. Try clicking
% in the diamond-shaped part of the figure, with the red dot.

%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% CAN'T CHANGE
%

% Define the geometry and mass properties of the robot.
robot = GetGeometryOfRobot;

% Run the simulation.
RunSimulation(robot,params);

end

function robot = GetGeometryOfRobot

% - wheel radius
robot.r = 1.2;

% - wheel half-width
robot.a = 0.25;

% - chassis half-width (x1)
robot.b = 1.25;

% - chassis quarter-height (z1)
robot.c = 0.2;

% - chassis length (y1)
robot.d = 1.8;

% - density (assumed uniform)
robot.chassis.rho = 3;
robot.wheels.rho = 1;

% - point of attachment between chassis and wheels
robot.p_12in1 = [-robot.b;0;robot.c];
robot.p_13in1 = [robot.b;0;robot.c];

% - position of each wheel with respect to the chassis
robot.o_2in1 = [-(robot.a+robot.b);0;robot.c];
robot.o_3in1 = [(robot.a+robot.b);0;robot.c];

% - the coefficient of friction at each joint
robot.k = 1;

% - force of gravity vector
robot.g_in0 = -9.81*[0;0;1];

% - mass and moment of inertia
[robot.m1,robot.J_1in1] = MassAndMomentOfInertiaOfChassis(robot.chassis.rho,2*robot.b,robot.d,4*robot.c);
[robot.m2,robot.J_2in2] = MassAndMomentOfInertiaOfWheel(robot.wheels.rho,robot.a,robot.r);
[robot.m3,robot.J_3in3] = MassAndMomentOfInertiaOfWheel(robot.wheels.rho,robot.a,robot.r);

% - colors
robot.colors.uiuc_orange=[1,0.6,0];
robot.colors.uiuc_blue=[0.4745,0.6471,0.9098];

% - vertices, faces, and colors for both wheels
n = 32;
p = [[robot.a;0;0] -[robot.a;0;0]];
ang = linspace(0,2*pi,n+1);
f1 = [];
f2 = [];
for i=1:n
    p = [p [0;robot.r*cos(ang(i));robot.r*sin(ang(i))]];
    f1 = [f1; [1 2+i 3+i]];
    f2 = [f2; [2 3+i 2+i]];
end
f = [f1;f2];
f(f==3+n)=3;
c = [repmat(robot.colors.uiuc_blue,floor(n/4),1);
     repmat(robot.colors.uiuc_orange,2*n-floor(n/4),1)];
robot.wheel2.p_in2 = p;
robot.wheel2.faces = f;
robot.wheel2.colors = c;
robot.wheel3.p_in3 = p;
robot.wheel3.faces = f;
robot.wheel3.colors = c;

% - vertices, faces, and colors for chassis
dx = 2*robot.b;
dy = robot.d;
dz = 4*robot.c;
p = [0.5*dx*[-1 1 1 -1 -1 1 1 -1];
     0.5*dy*[-1 -1 -1 -1 1 1 1 1];
     0.5*dz*[-1 -1 1 1 -1 -1 1 1]];
robot.chassis.p_in1 = p;
robot.chassis.faces =  [1 2 3;
                        3 4 1;
                        2 6 7;
                        7 3 2;
                        6 5 8;
                        8 7 6;
                        5 1 4;
                        4 8 5;
                        4 3 7;
                        7 8 4;
                        5 6 2;
                        2 1 5];
robot.chassis.colors = [repmat(robot.colors.uiuc_blue,2,1);
                        repmat(robot.colors.uiuc_orange,10,1)];

end

function RunSimulation(robot,params)

% Create empty figure.
world = [];
% Define time at which to start the simulation.
t = 0;
% Define time step.
dt = 4e-2;

%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% CAN CHANGE
%

% Define time limit.
tmax = 100;
% Define initial conditions (be very careful if you change these!)
% - position and orientation
theta1 = [0;0;0];
theta2 = [0;0;0];
theta3 = [0;0;0];
o_1in0 = [0;0;robot.r-robot.c];
o_2in0 = o_1in0+robot.o_2in1;
o_3in0 = o_1in0+robot.o_3in1;
% - linear and angular velocity
v_01in0 = zeros(3,1);
w_01in1 = zeros(3,1);
v_02in0 = zeros(3,1);
w_02in2 = zeros(3,1);
v_03in0 = zeros(3,1);
w_03in3 = zeros(3,1);
% - motor torques
u2 = 0;
u3 = 0;

%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% CAN'T CHANGE
%

% Either start making a movie or start storing actions.
global action done
done = false;
action = [u2;u3];
if (params.makemovie)
    load(params.action_filename);
    myV = VideoWriter(params.movie_filename,'MPEG-4');
    myV.Quality = 100;
    myV.FrameRate = 25;
    open(myV);
else
    actionRecord = [];
end

% Loop until break.
while (1)
    
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% MUST CHANGE
%
    
    % Compute: (orientations)
    %   
    %   Assume the use of ZYX Euler Angles (**not** XYZ!!!!).
    %
    %       theta1 is a 3x1 matrix of ZYX Euler Angles that describe the
    %       orientation of frame 1 (so theta1(1) is the angle of rotation
    %       about z0, and so forth)
    %
    %       theta2 and theta3 are the ZYX E.A.'s for frames 2 and 3,
    %       respectively
    %
    c2 = cos(theta1(2)); c3 = cos(theta1(3)); s2 = sin(theta1(2)); s3 = sin(theta1(3));
    phi = theta1(1);
    thetaa = theta1(2);
    psi = theta1(3); 
    R_1in0 = [cos(psi)*cos(thetaa) cos(psi)*sin(thetaa)*sin(phi)-sin(psi)*cos(phi) cos(psi)*sin(thetaa)*cos(phi)+sin(psi)*cos(phi);...
             sin(psi)*cos(thetaa) sin(psi)*sin(thetaa)*sin(phi)+cos(psi)*cos(phi) sin(psi)*sin(thetaa)*cos(phi)-cos(phi)*sin(phi);...
             -sin(thetaa) cos(thetaa)*sin(phi) cos(thetaa)*cos(phi)];           %ZYX euler angles from AE 483 labs 
    R_2in1 = [1 0 0;
              0 c2 -s2;
              0 s2 c2];
    R_2in0 = R_2in1*R_1in0;
    R_3in1 = [1 0 0;
              0 c3 -s3;
              0 s3 c3];
    R_3in0 = R_3in1*R_1in0;
    
    % Compute: (coordinate transformations)
    robot.chassis.p_in0 = R_1in0*robot.chassis.p_in1 + [o_1in0 o_1in0 o_1in0 o_1in0 o_1in0 o_1in0 o_1in0 o_1in0];
    robot.wheel2.p_in0 = R_2in0*robot.wheel2.p_in2 + [o_2in0 o_2in0 o_2in0 o_2in0 o_2in0 o_2in0 o_2in0 o_2in0 o_2in0 o_2in0 o_2in0 o_2in0 o_2in0 o_2in0 o_2in0 o_2in0 o_2in0 o_2in0 o_2in0 o_2in0 o_2in0 o_2in0 o_2in0 o_2in0 o_2in0 o_2in0 o_2in0 o_2in0 o_2in0 o_2in0 o_2in0 o_2in0 o_2in0 o_2in0 ];
    robot.wheel3.p_in0 = R_3in0*robot.wheel3.p_in3 + [o_3in0 o_3in0 o_3in0 o_3in0 o_3in0 o_3in0 o_3in0 o_3in0 o_3in0 o_3in0 o_3in0 o_3in0 o_3in0 o_3in0 o_3in0 o_3in0 o_3in0 o_3in0 o_3in0 o_3in0 o_3in0 o_3in0 o_3in0 o_3in0 o_3in0 o_3in0 o_3in0 o_3in0 o_3in0 o_3in0 o_3in0 o_3in0 o_3in0 o_3in0 ];
    
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% CAN'T CHANGE
%
    
    % Update the figure.
    world = UpdateFigure(world,robot,params,o_1in0,R_1in0,o_2in0,R_2in0,o_3in0,R_3in0,u2,u3,t,tmax);
    
    % If making a movie, store the current figure as a frame.
    if (params.makemovie)
        frame = getframe(gcf);
        writeVideo(myV,frame);
    end
    
    % Stop if time has reached its maximum.
    if ((t>=tmax)||done)
        break;
    end
    
    % Either store or retrieve the action.
    if (params.makemovie)
        [actionRecord,curaction,done] = RetrieveAction(actionRecord);
        action = curaction;
    else
        curaction = action;
        actionRecord = StoreAction(actionRecord,curaction);
    end
    
    % Compute input torques applied by SC to each RW.
    u2 = curaction(1);
    u3 = curaction(2);
    
    % Solve ODEs.
    [t,o_1in0,o_2in0,o_3in0,theta1,theta2,theta3,v_01in0,v_02in0,v_03in0,w_01in1,w_02in2,w_03in3] = ...
            Simulate(t,dt,...
                     o_1in0,o_2in0,o_3in0,theta1,theta2,theta3,...
                     v_01in0,v_02in0,v_03in0,w_01in1,w_02in2,w_03in3,...
                     u2,u3,...
                     robot);
    
end
% Either close the movie or save the record of actions.
if (params.makemovie)
    for i=1:myV.FrameRate
        frame = getframe(gcf);
        writeVideo(myV,frame);
    end
    close(myV);
else
    save(params.action_filename,'actionRecord');
end

if (params.makesnapshot)
    set(gcf,'paperorientation','landscape');
    set(gcf,'paperunits','normalized');
    set(gcf,'paperposition',[0 0 1 1]);
    print(gcf,'-dpdf',params.snapshot_filename);
end

end
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% MUST CHANGE TODO
%

function [o_1in0dot,o_2in0dot,o_3in0dot,theta1dot,theta2dot,theta3dot,v_01in0dot,v_02in0dot,v_03in0dot,w_01in1dot,w_02in2dot,w_03in3dot] = ...
    GetRates(o_1in0,o_2in0,o_3in0,theta1,theta2,theta3,v_01in0,v_02in0,v_03in0,w_01in1,w_02in2,w_03in3,u2,u3,robot)

%F = [];
%h = [];

%gamma = F\h;
% gamma(1:3) = o_1in0dot;
% gamma(4:6) = o_2in0dot;
% gamma(7:9) = o_3in0dot;
% gamma(10:12) = theta1dot;
% gamma(13:15) = theta2dot;
% gamma(16:18) = theta3dot;
% gamma(19:21) = v_01in0dot;
% gamma(22:24) = v_02in0dot;
% gamma(25:27) = v_03in0dot;
% gamma(28:30) = w_01in1dot;
% gamma(31:33) = w_02in2dot;
% gamma(34:36) = w_03in3dot;



o_1in0dot = zeros(3,1);
o_2in0dot = zeros(3,1);
o_3in0dot = zeros(3,1);
theta1dot = zeros(3,1);
theta2dot = zeros(3,1);
theta3dot = zeros(3,1);
v_01in0dot = zeros(3,1);
v_02in0dot = zeros(3,1);
v_03in0dot = zeros(3,1);
w_01in1dot = zeros(3,1);
w_02in2dot = zeros(3,1);
w_03in3dot = zeros(3,1);

end

%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% CAN'T CHANGE
%

function actionRecord = StoreAction(actionRecord,action)
actionRecord(:,end+1) = action;
end

function [actionRecord,action,done] = RetrieveAction(actionRecord)
action = actionRecord(:,1);
actionRecord = actionRecord(:,2:end);
done = isempty(actionRecord);
end

function [t,o_1in0,o_2in0,o_3in0,theta1,theta2,theta3,v_01in0,v_02in0,v_03in0,w_01in1,w_02in2,w_03in3] = ...
            Simulate(t,dt,...
                     o_1in0,o_2in0,o_3in0,theta1,theta2,theta3,...
                     v_01in0,v_02in0,v_03in0,w_01in1,w_02in2,w_03in3,...
                     u2,u3,...
                     robot)
[t,x] = ode45(@(t,x) GetXDot(t,x,u2,u3,robot),[t t+dt],...
   [o_1in0;o_2in0;o_3in0;theta1;theta2;theta3;v_01in0;v_02in0;v_03in0;w_01in1;w_02in2;w_03in3]);
x = x';
t = t(end);
[o_1in0,o_2in0,o_3in0,theta1,theta2,theta3,v_01in0,v_02in0,v_03in0,w_01in1,w_02in2,w_03in3] = XToState(x);
end

function xdot = GetXDot(t,x,u2,u3,robot)
% Unpack the state.
[o_1in0,o_2in0,o_3in0,theta1,theta2,theta3,v_01in0,v_02in0,v_03in0,w_01in1,w_02in2,w_03in3] = XToState(x);
% Get time derivatives.
[o_1in0dot,o_2in0dot,o_3in0dot,theta1dot,theta2dot,theta3dot,v_01in0dot,v_02in0dot,v_03in0dot,w_01in1dot,w_02in2dot,w_03in3dot] = ...
    GetRates(o_1in0,o_2in0,o_3in0,theta1,theta2,theta3,v_01in0,v_02in0,v_03in0,w_01in1,w_02in2,w_03in3,u2,u3,robot);
% Pack time derivatives.
xdot = [o_1in0dot;o_2in0dot;o_3in0dot;theta1dot;theta2dot;theta3dot;v_01in0dot;v_02in0dot;v_03in0dot;w_01in1dot;w_02in2dot;w_03in3dot];
end

function [o_1in0,o_2in0,o_3in0,theta1,theta2,theta3,v_01in0,v_02in0,v_03in0,w_01in1,w_02in2,w_03in3] = XToState(x)
o_1in0 = x(1:3,end);
o_2in0 = x(4:6,end);
o_3in0 = x(7:9,end);
theta1 = x(10:12,end);
theta2 = x(13:15,end);
theta3 = x(16:18,end);
v_01in0 = x(19:21,end);
v_02in0 = x(22:24,end);
v_03in0 = x(25:27,end);
w_01in1 = x(28:30,end);
w_02in2 = x(31:33,end);
w_03in3 = x(34:36,end);
end

function robotfig = DrawRobot(robotfig,robot,alpha)
if isempty(robotfig)
    % - links
    robotfig.chassis = patch('Vertices',robot.chassis.p_in0','Faces',robot.chassis.faces,'FaceVertexCData',robot.chassis.colors,'FaceColor','flat',...
                          'FaceAlpha',alpha,'EdgeAlpha',alpha,...
                          'backfacelighting','reverselit','AmbientStrength',0.6);
	robotfig.wheel2 = patch('Vertices',robot.wheel2.p_in0','Faces',robot.wheel2.faces,'FaceVertexCData',robot.wheel2.colors,'FaceColor','flat',...
                          'FaceAlpha',alpha,'EdgeAlpha',alpha,...
                          'backfacelighting','reverselit','AmbientStrength',0.6,'linewidth',0.01);
	robotfig.wheel3 = patch('Vertices',robot.wheel3.p_in0','Faces',robot.wheel3.faces,'FaceVertexCData',robot.wheel3.colors,'FaceColor','flat',...
                          'FaceAlpha',alpha,'EdgeAlpha',alpha,...
                          'backfacelighting','reverselit','AmbientStrength',0.6,'linewidth',0.01);
else
    set(robotfig.chassis,'vertices',robot.chassis.p_in0');
    set(robotfig.wheel2,'vertices',robot.wheel2.p_in0');
    set(robotfig.wheel3,'vertices',robot.wheel3.p_in0');
end
end

function frame = DrawFrame(frame,o,R)
p = [o repmat(o,1,3)+R];
if isempty(frame)
    frame.x = plot3(p(1,[1 2]),p(2,[1 2]),p(3,[1 2]),'r-','linewidth',4);
    frame.y = plot3(p(1,[1 3]),p(2,[1 3]),p(3,[1 3]),'g-','linewidth',4);
    frame.z = plot3(p(1,[1 4]),p(2,[1 4]),p(3,[1 4]),'b-','linewidth',4);
else
    set(frame.x,'xdata',p(1,[1 2]),'ydata',p(2,[1 2]),'zdata',p(3,[1 2]));
    set(frame.y,'xdata',p(1,[1 3]),'ydata',p(2,[1 3]),'zdata',p(3,[1 3]));
    set(frame.z,'xdata',p(1,[1 4]),'ydata',p(2,[1 4]),'zdata',p(3,[1 4]));
end
end

function world = CreateFigure(robot,params,o_1in0,R_1in0,o_2in0,R_2in0,o_3in0,R_3in0,u2,u3,t,tmax)
global inputaxis
% - clear the current figure
clf;
% - text (it's important this is in the back, so you can rotate the view
%         and other stuff!)
axes('position',[0 0 1 1]);
axis([0 1 0 1]);
hold on;
axis off;
fs = 10;
world.text.label=text(0.15,0.95,'view: frame 0','fontweight','bold','fontsize',fs);
world.text.time=text(0.05,0.1,sprintf('t = %6.2f / %6.2f\n',t,tmax),'fontsize',fs,'verticalalignment','top','fontname','monaco');
world.text.teamname=text(0.05,0.04,params.teamname,'fontsize',fs,'verticalalignment','top','fontweight','bold');
world.text.torques=text(0.85,0.02,sprintf('u_2 = %6.1f\nu_3 = %6.1f\n',u2,u3),'fontsize',fs,'fontname','monaco','verticalalignment','bottom');
% - inputs
inputaxis = axes('position',[0.55 0.05 0.3 0.3]);
axis equal;
axis(10*[-1 1 -1 1]);
axis manual;
hold on;
fill(10*[-1 0 1 0 -1],10*[0 -1 0 1 0],'w','linewidth',2);
world.input.p = plot(-u2+u3,-u2-u3,'r.','markersize',24);
axis off;
% - view from frame 0
axes('position',[0.05 0.3 .9 .7]);
set(gcf,'renderer','opengl');
axis equal;
axis([-8 8 -8 8 0 4]);
axis manual;
hold on;
view([90-37.5,20]);
box on;
set(gca,'projection','perspective');
set(gca,'clipping','on','clippingstyle','3dbox');
world.view0.robot = DrawRobot([],robot,0.6);
world.view0.frame0 = DrawFrame([],zeros(3,1),eye(3));
world.view0.frame1 = DrawFrame([],o_1in0,R_1in0);
world.view0.frame2 = DrawFrame([],o_2in0,R_2in0);
world.view0.frame3 = DrawFrame([],o_3in0,R_3in0);
lighting gouraud
world.view0.light = light('position',zeros(3,1)','style','local');
% - make the figure respond to key commands
set(gcf,'KeyPressFcn',@onkeypress_nokeypad);
set(gcf,'WindowButtonDownFcn',@onbuttondown);
end

function world = UpdateFigure(world,robot,params,o_1in0,R_1in0,o_2in0,R_2in0,o_3in0,R_3in0,u2,u3,t,tmax)
if (isempty(world))
    world = CreateFigure(robot,params,o_1in0,R_1in0,o_2in0,R_2in0,o_3in0,R_3in0,u2,u3,t,tmax);
else
    world.view0.robot = DrawRobot(world.view0.robot,robot);
    world.view0.frame1 = DrawFrame(world.view0.frame1,o_1in0,R_1in0);
    world.view0.frame2 = DrawFrame(world.view0.frame2,o_2in0,R_2in0);
    world.view0.frame3 = DrawFrame(world.view0.frame3,o_3in0,R_3in0);
    set(world.input.p,'xdata',-u2+u3,'ydata',-u3-u2);
    set(world.view0.light,'position',(o_3in0+R_3in0*[0;0;3*robot.c])');
    set(world.text.time,'string',sprintf('t = %6.2f / %6.2f\n',t,tmax));
    set(world.text.torques,'string',sprintf('u_2 = %6.2f\nu_3 = %6.2f\n',u2,u3));
end
drawnow
end

function onbuttondown(src,event)
global inputaxis action
p=get(inputaxis,'CurrentPoint');
p=p(1,1:2)';
if (abs(p(2))<10-abs(p(1)))
    action(1,1) = -0.5*(p(1)+p(2));
    action(2,1) = 0.5*(p(1)-p(2));
end
set(gcf,'WindowButtonMotionFcn',@onbuttonmotion);
set(gcf,'WindowButtonUpFcn',@onbuttonup);
set(gcf,'WindowButtonDownFcn',[]);
end

function onbuttonup(src,event)
set(gcf,'WindowButtonMotionFcn',[]);
set(gcf,'WindowButtonUpFcn',[]);
set(gcf,'WindowButtonDownFcn',@onbuttondown);
end

function onbuttonmotion(src,event)
global inputaxis action
p=get(inputaxis,'CurrentPoint');
p=p(1,1:2)';
if (abs(p(2))<10-abs(p(1)))
    action(1,1) = -0.5*(p(1)+p(2));
    action(2,1) = 0.5*(p(1)-p(2));
end
end

function onkeypress_nokeypad(src,event)
global action done
du = 1;
if event.Character == '1'
    action(1,1) = action(1,1)+du;
elseif event.Character == '!'
    action(1,1) = action(1,1)-du;
elseif event.Character == '2'
    action(2,1) = action(2,1)+du;
elseif event.Character == '@'
    action(2,1) = action(2,1)-du;
elseif event.Character == '3'
    action(3,1) = action(3,1)+du;
elseif event.Character == '#'
    action(3,1) = action(3,1)-du;
elseif event.Character == 'q'
    done = true;
end
end

function [m,J] = MassAndMomentOfInertiaOfChassis(rho,x,y,z)
% - assumes uniform density
m = rho*x*y*z;
J = (m/12)*diag([y^2+z^2,z^2+x^2,x^2+y^2]);
end

function [m,J] = MassAndMomentOfInertiaOfWheel(rho,a,r)
% - assumes uniform density
m = rho*(pi*a*r^2)/3;
J = (m/10)*diag([6*r^2,2*a^2+3*r^2,2*a^2+3*r^2]);
end

%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
