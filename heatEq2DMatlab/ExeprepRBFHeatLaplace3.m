function [bigLmatrix bigDampMatrix initdatavec xnodes ynodes rhoVec tripleVec] = ...
ExeprepRBFHeatLaplace3(N,GAshp,stencilsize,polydegree,...
    xlb,xub,ylb,yub,c1,c2,rho1,rho2,xnodes,ynodes,nearestneighbors,...
    totalmovements,plotflag,numIntNodes,intWrapFlag,...
    polydegreeInt,overlapTrigger,stencilsizeInt,naiveFlag,dampLk,...
    const1,const2,const3,yLI,yUI,queryFactor,RBFwarpFlag,thinFlag,curvedFlag)

% Edit 1 2/15 switching to heat/laplace; making nodes periodic in x.

global cFlag;
cFlag = curvedFlag;

% We first set up the domain and initial conditions.

rhoVec = zeros(N,1);

% Below: creating a new node set of (xnodes,ynodes) (if those are needed)

if size(xnodes,1) == 1
    xnodes = rand(N,1)*(xub-xlb)+xlb;
    ynodes = rand(N,1)*(yub-ylb)+ylb;
    
    if intWrapFlag == 1
       
       hInt = 1/numIntNodes;
       prexgrid = linspace(0,1,numIntNodes+1);
       xgrid = (prexgrid(1,1:numIntNodes))';
       [y1 yprime1 theta1] = curvedinterface1(xgrid,yLI);
       [y2 yprime2 theta2] = curvedinterface2(xgrid,yUI);
       
       if thinFlag == 0
           xnodes(1:numIntNodes,1) = xgrid + sin(theta1)*hInt*0.5;
           ynodes(1:numIntNodes,1) = (curvedinterface1(xgrid,yLI)-0.5*cos(theta1)*hInt);
           xnodes(1+numIntNodes:2*numIntNodes,1) = xgrid - sin(theta1)*hInt*0.5;
           ynodes(1+numIntNodes:2*numIntNodes,1) = (curvedinterface1(xgrid,yLI)+0.5*hInt*cos(theta1));
           xnodes(1+2*numIntNodes:3*numIntNodes,1) = xgrid + sin(theta1)*hInt*(0.5+3^0.5/2)+hInt*0.5;
           ynodes(1+2*numIntNodes:3*numIntNodes,1) = (curvedinterface1(xgrid,yLI)-(0.5+3^0.5/2)*cos(theta1)*hInt);
           xnodes(1+3*numIntNodes:4*numIntNodes,1) = xgrid - sin(theta1)*hInt*(0.5+3^0.5/2)+hInt*0.5;
           ynodes(1+3*numIntNodes:4*numIntNodes,1) = (curvedinterface1(xgrid,yLI)+(0.5+3^0.5/2)*hInt*cos(theta1));
           xnodes(1+4*numIntNodes:5*numIntNodes,1) = xgrid + sin(theta1)*hInt*(0.5+3^0.5);
           ynodes(1+4*numIntNodes:5*numIntNodes,1) = (curvedinterface1(xgrid,yLI)-(0.5+3^0.5)*cos(theta1)*hInt);
           xnodes(1+5*numIntNodes:6*numIntNodes,1) = xgrid - sin(theta1)*hInt*(0.5+3^0.5);
           ynodes(1+5*numIntNodes:6*numIntNodes,1) = (curvedinterface1(xgrid,yLI)+(0.5+3^0.5)*hInt*cos(theta1));
           
           xnodes(1+6*numIntNodes:7*numIntNodes,1) = xgrid + sin(theta2)*hInt*0.5;
           ynodes(1+6*numIntNodes:7*numIntNodes,1) = (curvedinterface2(xgrid,yUI)-0.5*hInt*cos(theta2));
           xnodes(1+7*numIntNodes:8*numIntNodes,1) = xgrid - sin(theta2)*hInt*0.5;
           ynodes(1+7*numIntNodes:8*numIntNodes,1) = (curvedinterface2(xgrid,yUI)+0.5*hInt*cos(theta2));
           xnodes(1+8*numIntNodes:9*numIntNodes,1) = xgrid + sin(theta2)*hInt*(0.5+3^0.5/2)+hInt*0.5;
           ynodes(1+8*numIntNodes:9*numIntNodes,1) = (curvedinterface2(xgrid,yUI)-(0.5+3^0.5/2)*hInt*cos(theta2));
           xnodes(1+9*numIntNodes:10*numIntNodes,1) = xgrid - sin(theta2)*hInt*(0.5+3^0.5/2)+hInt*0.5;
           ynodes(1+9*numIntNodes:10*numIntNodes,1) = (curvedinterface2(xgrid,yUI)+(0.5+3^0.5/2)*hInt*cos(theta2));
           xnodes(1+10*numIntNodes:11*numIntNodes,1) = xgrid + sin(theta2)*hInt*(0.5+3^0.5);
           ynodes(1+10*numIntNodes:11*numIntNodes,1) = (curvedinterface2(xgrid,yUI)-(0.5+3^0.5)*hInt*cos(theta2));
           xnodes(1+11*numIntNodes:12*numIntNodes,1) = xgrid - sin(theta2)*hInt*(0.5+3^0.5);
           ynodes(1+11*numIntNodes:12*numIntNodes,1) = (curvedinterface2(xgrid,yUI)+(0.5+3^0.5)*hInt*cos(theta2));
       else
           xnodes(1:numIntNodes,1) = xgrid + sin(theta1)*hInt*0.5;
           ynodes(1:numIntNodes,1) = (curvedinterface1(xgrid,yLI)+curvedinterface2(xgrid,yUI))/2-0.5*cos(theta1)*hInt;
           xnodes(1+numIntNodes:2*numIntNodes,1) = xgrid - sin(theta1)*hInt*0.5;
           ynodes(1+numIntNodes:2*numIntNodes,1) = (curvedinterface1(xgrid,yLI)+curvedinterface2(xgrid,yUI))/2+0.5*hInt*cos(theta1);
           xnodes(1+2*numIntNodes:3*numIntNodes,1) = xgrid + sin(theta1)*hInt*(0.5+3^0.5/2)+hInt*0.5;
           ynodes(1+2*numIntNodes:3*numIntNodes,1) = (curvedinterface1(xgrid,yLI)+curvedinterface2(xgrid,yUI))/2-(0.5+3^0.5/2)*cos(theta1)*hInt;
           xnodes(1+3*numIntNodes:4*numIntNodes,1) = xgrid - sin(theta1)*hInt*(0.5+3^0.5/2)+hInt*0.5;
           ynodes(1+3*numIntNodes:4*numIntNodes,1) = (curvedinterface1(xgrid,yLI)+curvedinterface2(xgrid,yUI))/2+(0.5+3^0.5/2)*hInt*cos(theta1);
           xnodes(1+4*numIntNodes:5*numIntNodes,1) = xgrid + sin(theta1)*hInt*(0.5+3^0.5);
           ynodes(1+4*numIntNodes:5*numIntNodes,1) = (curvedinterface1(xgrid,yLI)+curvedinterface2(xgrid,yUI))/2-(0.5+3^0.5)*cos(theta1)*hInt;
           xnodes(1+5*numIntNodes:6*numIntNodes,1) = xgrid - sin(theta1)*hInt*(0.5+3^0.5);
           ynodes(1+5*numIntNodes:6*numIntNodes,1) = (curvedinterface1(xgrid,yLI)+curvedinterface2(xgrid,yUI))/2+(0.5+3^0.5)*hInt*cos(theta1);
       end
       %{
       xnodes(1+12*numIntNodes:13*numIntNodes,1) = xgrid + sin(theta1)*hInt*(0.5+1.5*3^0.5)+hInt*0.5;
       ynodes(1+12*numIntNodes:13*numIntNodes,1) = (curvedinterface1(xgrid)-(0.5+1.5*3^0.5)*cos(theta1)*hInt);
       xnodes(1+13*numIntNodes:14*numIntNodes,1) = xgrid - sin(theta1)*hInt*(0.5+1.5*3^0.5)+hInt*0.5;
       ynodes(1+13*numIntNodes:14*numIntNodes,1) = (curvedinterface1(xgrid)+(0.5+1.5*3^0.5)*hInt*cos(theta1));
       xnodes(1+14*numIntNodes:15*numIntNodes,1) = xgrid + sin(theta2)*hInt*(0.5+1.5*3^0.5)+hInt*0.5;
       ynodes(1+14*numIntNodes:15*numIntNodes,1) = (curvedinterface2(xgrid)-(0.5+1.5*3^0.5)*hInt*cos(theta2));
       xnodes(1+15*numIntNodes:16*numIntNodes,1) = xgrid - sin(theta2)*hInt*(0.5+1.5*3^0.5)+hInt*0.5;
       ynodes(1+15*numIntNodes:16*numIntNodes,1) = (curvedinterface2(xgrid)+(0.5+1.5*3^0.5)*hInt*cos(theta2));
       %}
    end
    
    preXint = linspace(0,1,numIntNodes+1);
    xInt = preXint(1,1:numIntNodes);
    
    xnodes(N-numIntNodes+1:N,1) = xInt';
    xnodes(N-2*numIntNodes+1:N-numIntNodes,1) = xInt';
    ynodes(N-numIntNodes+1:N,1) = ones(numIntNodes,1);
    ynodes(N-2*numIntNodes+1:N-numIntNodes,1) = zeros(numIntNodes,1);
    
    tic;

    for movement_iteration = 1:totalmovements
        movement_iteration
        [xnodes ynodes] = mos2dsqperiodic7(xnodes,ynodes,...
        (0.05*(2500/N)^0.5)/movement_iteration,nearestneighbors,xlb,xub,ylb,yub,...
        numIntNodes,intWrapFlag,yLI,yUI,thinFlag);
    
        % here, we may enable or disable plotting the nodes while the node set
        % is being created.
    
        if plotflag == 1
            figure(1)
    
            plot(xnodes,ynodes,'.k')
            axis([xlb xub ylb yub])
            hold on;
            xgridPlot = linspace(0,1,100);
            ygridPlot1 = curvedinterface1(xgridPlot,yLI);
            ygridPlot2 = curvedinterface2(xgridPlot,yUI);
            plot(xgridPlot,ygridPlot1,'--k',xgridPlot,ygridPlot2,'--k');
            hold off;
        end
    end
    disp('For node set creation:')
    toc;
    disp(' ')
end

% Below: assigning the values of lambda and mu at each node

seqVec1 = zeros(N,1);
seqVec2 = zeros(N,1);

for k = 1:N
    if ynodes(k,1) <= curvedinterface2(xnodes(k,1),yUI) && ynodes(k,1) >= curvedinterface1(xnodes(k,1),yLI) %curvedinterface(xnodes(k,1))
        rhoVec(k,1) = rho2+const1*sin(const2*pi*xnodes(k,1))*sin(const3*pi*ynodes(k,1));
        seqVec2(k,1) = 1;
    else
        rhoVec(k,1) = rho1;
        seqVec1(k,1) = 1;
    end
end

rhoMatrix = sparse(1:N,1:N,rhoVec,N,N);

% Next, we create sparse, diagonal lambda and mu matrices to aid us in
% creating the large differential operator that we will call to convect
% waves.

% IC creation

p = zeros(N,1);  

initdatavec = p;

% Below: setting up dx/dy and hyperviscosity matrix operators

tic;

[preLmatrix tripleVec] = ...
    createRBFLoperator1(xnodes,ynodes,xlb,xub,ylb,yub,GAshp,...
    stencilsize,polydegree,seqVec1,seqVec2,...
    c1,rho1,c2,rho2,polydegreeInt,...
    stencilsizeInt,naiveFlag,1,yLI,yUI,queryFactor,numIntNodes,RBFwarpFlag);
%{
bigDampMatrix = ...
    createRBFLoperator1(xnodes,ynodes,xlb,xub,ylb,yub,GAshp,...
    stencilsize,polydegree,seqVec1,seqVec2,...
    c1,rho1,c2,rho2,polydegreeInt,...
    stencilsizeInt,naiveFlag,dampLk,yLI,yUI,queryFactor);
    %}
    bigDampMatrix = 1;

bigLmatrix = rhoMatrix*preLmatrix;

disp('For matrix operator creation:')
toc;
disp(' ')

%{
[origidxstackSeq1 origidxstackSeq2] = findperiodicneighborsSeq1(xnodes,ynodes,xnodes,ynodes,...
    xlb,xub,ylb,yub,stencilsize,seqVec1,seqVec2);
%}
%%% End function ExeprepRBF6inline %%%

end


function [y yprime theta] = curvedinterface1(x,yLI)

% function CURVEDINTERFACE creates a simple, slightly curved interface that
% is periodically C1 at the left and right boundaries of the unit square,
% and C-inf everywhere else.
global cFlag;
if cFlag ~= 0
    y = 0.02*sin(2*pi*x)+yLI*ones(size(x));
    yprime = 0.04*pi*cos(2*pi*x);
    theta = atan(yprime);
else
    y = yLI*ones(size(x));
    yprime = zeros(size(x));
    theta = zeros(size(x));
end

end

function [y yprime theta] = curvedinterface2(x,yUI)

% function CURVEDINTERFACE creates a simple, slightly curved interface that
% is periodically C1 at the left and right boundaries of the unit square,
% and C-inf everywhere else.
global cFlag;
if cFlag ~= 0
    y = 0.02*sin(2*pi*x)+yUI*ones(size(x));
    yprime = 0.04*pi*cos(2*pi*x);
    theta = atan(yprime);
else
    y = yUI*ones(size(x));
    yprime = zeros(size(x));
    theta = zeros(size(x));
end

end


function [xnew ynew] = mos2dsqperiodic7(x,y,delta,nnn,xlb,xub,ylb,yub,numIntNodes,intWrapFlag,yLI,yUI,thinFlag)

% function MOS2DSQPERIODIC7 moves RBF-FD nodes through one step of
% electrostatic repulsion (by distance DELTA).

% ver 7: one interface at y = 0.5; another at 0.25.

% IN: 

% x: x-coordinates of RBF-FD nodes
% y: y-coordinates "             "
% delta: distance to move nodes along force vector determined by electrostatic
% repulsion
% nnn: number of nearest neighbors to use in calculating electrostatic
% force vector
% xlb, etc. : lower and upper bounds of periodic domain in x and y
% numIntNodes: number of interface nodes to throw down
% intWrapFlag: if 0: don't wrap int's; if 1: do.

% OUT:

% xnew: new x-coordinates for RBF-FD nodes
% ynew: new y-coordinates "              "

%%% BEGIN function mos2dsqperiodic6 %%%

xcorr = zeros(size(x));  % xcorr and ycorr will hold the corrections
ycorr = zeros(size(y));  % (displacements) to move nodes by one step.

nnn = nnn+1;  % when performing knnsearches, we'll throw out the returned
              % identity indices (in the first slot of index matrices)

% The first (small) knn search is for finding out how much of the domain we
% should "tile" to ensure correct identification of periodic nearest
% neighbors near the boundaries.
              
[idx dist] = knnsearch([x y],[x(1:20,1) y(1:20,1)],'k',nnn);

avgdist = sum(dist(:,size(dist,2)))/size(dist,1);
safedist = 2*avgdist;

% The first FOR loop (below) finds out how many nodes we have to "tile."

counter = 0;

for m = 1:size(x,1)
    
    if xub-x(m,1)<=safedist
        counter = counter+1;
    end
    
    if x(m,1)-xlb<=safedist
        counter = counter+1;
    end
%{    
    if yub-y(m,1)<=safedist
        counter = counter+1;
    end
    
    if y(m,1)-ylb<=safedist
        counter = counter+1;
    end
    
    if xub-x(m,1)<=safedist
        if yub-y(m,1)<=safedist
        counter = counter+1;
        end
    end
    
    if xub-x(m,1)<=safedist
        if y(m,1)-ylb<=safedist
        counter = counter+1;
        end
    end
    
    if x(m,1)-xlb<=safedist
        if yub-y(m,1)<=safedist
        counter = counter+1;
        end
    end
    
    if x(m,1)-xlb<=safedist
        if y(m,1)-ylb<=safedist
        counter = counter+1;
        end
    end
    %}
end

% Here, we initialize OVERLAP vectors to hold coordinates for tiled nodes.

xoverlap = zeros(counter,1);
yoverlap = zeros(counter,1);

xspan = xub-xlb;
yspan = yub-ylb;

% The second FOR loop (below) actually assigns appropriate coordinates to
% "tiled" nodes.

counter = 1;

for m = 1:size(x,1)
    
    if xub-x(m,1)<=safedist
        xoverlap(counter,1)=x(m,1)-xspan;
        yoverlap(counter,1)=y(m,1);
        counter = counter+1;
    end
    
    if x(m,1)-xlb<=safedist
        xoverlap(counter,1)=x(m,1)+xspan;
        yoverlap(counter,1)=y(m,1);
        counter = counter+1;
    end
    %{
    if yub-y(m,1)<=safedist
        yoverlap(counter,1)=y(m,1)-yspan;
        xoverlap(counter,1)=x(m,1);
        counter = counter+1;
    end
    
    if y(m,1)-ylb<=safedist
        yoverlap(counter,1)=y(m,1)+yspan;
        xoverlap(counter,1)=x(m,1);
        counter = counter+1;
    end
    
    if xub-x(m,1)<=safedist
        if yub-y(m,1)<=safedist
        xoverlap(counter,1)=x(m,1)-xspan;
        yoverlap(counter,1)=y(m,1)-yspan;
        counter = counter+1;
        end
    end
    
    if xub-x(m,1)<=safedist
        if y(m,1)-ylb<=safedist
        xoverlap(counter,1)=x(m,1)-xspan;
        yoverlap(counter,1)=y(m,1)+yspan;
        counter = counter+1;
        end
    end
    
    if x(m,1)-xlb<=safedist
        if y(m,1)-ylb<=safedist
        xoverlap(counter,1)=x(m,1)+xspan;
        yoverlap(counter,1)=y(m,1)+yspan;
        counter = counter+1;
        end
    end
    
    if x(m,1)-xlb<=safedist
        if yub-y(m,1)<=safedist
        xoverlap(counter,1)=x(m,1)+xspan;
        yoverlap(counter,1)=y(m,1)-yspan;
        counter = counter+1;
        end
    end
    %}
end

xaug = [x; xoverlap];  % x- and y- coordinates augmented with tiled nodes
yaug = [y; yoverlap];
    
% Now, we actually find nearest neighbors in the augmented domain

[idx dist] = knnsearch([xaug yaug],[x y],'k',nnn);

idxmod = idx(:,2:nnn);
distmod = dist(:,2:nnn);

oneoverr5 = 1./(distmod.^5); % we use a relation of 1/r^4 in calculating
                             % an electrostatic repulsion vector.  One
                             % power of radius is already included in the
                             % numerator (effectively)

if intWrapFlag == 0
    startM = 1;
else
    if thinFlag == 0
        startM = numIntNodes*12;
    else
        startM = numIntNodes*6;
    end
end           
    
for m = (startM+1):(size(x,1)-2*numIntNodes)
    
    for n = 1:nnn-1
        
        % we sum up contributions to the force vector from NNN nearest
        % neighbors...
        
        xcorr(m,1) = xcorr(m,1)+(x(m,1)-xaug(idxmod(m,n),1)) ...
            *oneoverr5(m,n);
        ycorr(m,1) = ycorr(m,1)+(y(m,1)-yaug(idxmod(m,n),1)) ...
            *oneoverr5(m,n);
        
    end
    
    % ... and then normalize those force vectors.
    
    xycorrlength = (xcorr(m,1)^2+ycorr(m,1)^2)^0.5;
    xcorr(m,1) = xcorr(m,1)/xycorrlength;
    ycorr(m,1) = ycorr(m,1)/xycorrlength;
    
end

% we move each node by a distance DELTA.

xnew = x+xcorr*delta;
ynew = y+ycorr*delta;

% And finally, we make sure to "wrap" the nodes to the other side of the
% domain if they exit it through the movement step.

hInt = xnew(5,1)-xnew(4,1);

for k = 1:size(xnew,1)
    
    if k <= (size(x,1)-2*numIntNodes)
        
        if xnew(k,1) >= xub
            xnew(k,1) = xnew(k,1)-xspan;
        end
        if xnew(k,1) <= xlb
            xnew(k,1) = xnew(k,1)+xspan;
        end
        if ynew(k,1) >= yub
            ynew(k,1) = ynew(k,1)-yspan;
        end
        if ynew(k,1) <= ylb
            ynew(k,1) = ynew(k,1)+yspan;
        end
        
    end
    
    if k > startM && (k <= (size(x,1)-2*numIntNodes))
    
        if intWrapFlag ~= 0

            if abs(ynew(k,1)-curvedinterface2(xnew(k,1),yUI)) <= (3^0.5+0.5)*hInt
                ynew(k,1) = ylb+yspan*rand;
            end
            if abs(ynew(k,1)-curvedinterface1(xnew(k,1),yLI)) <= (3^0.5+0.5)*hInt
                ynew(k,1) = ylb+yspan*rand;
            end

        end
    
    end
        
end

%%% End function mos2dsqperiodic %%%

end



function [sparseLmatrix tripleVec] = ...
    createRBFLoperator1(xnodes,ynodes,xlb,xub,ylb,yub,shp,stencilsize,...
    polydegree,seqVec1,seqVec2,c1,rho1,c2,rho2,polydegreeInt,...
    stencilsizeInt,naiveFlag,Lk,yLI,yUI,queryFactor,numIntNodes,RBFwarpFlag)

%%% BEGIN function CREATERBFHYPOPERATORS6 %%%

% First, we define the size of our operator.

N1 = size(xnodes,1);

% Next, we call FINDPERIODICNEIGHBORS6 to find periodic nearest neighbors for all 
% RBF-FD nodes in the domain.  ORIGIDXSTACK holds the original indices
% (locations in [xnodes ynodes] vector pair) for the
% STENCILSIZE nearest neighbors (columns) of each of the N1 RBF-FD evaluation nodes
% (rows).

origidxstack = findperiodicneighbors6(xnodes,ynodes,xnodes,ynodes,xlb,xub,ylb,yub,stencilsize);
origidxstackInt = findperiodicneighbors6(xnodes,ynodes,xnodes,ynodes,xlb,xub,ylb,yub,stencilsizeInt);
[origidxstackSeq1 origidxstackSeq2] = findperiodicneighborsSeq1(xnodes,ynodes,xnodes,ynodes,...
    xlb,xub,ylb,yub,stencilsize,seqVec1,seqVec2);

% the KNNSEARCH below outputs the squared euclidean distance between each
% RBF-FD node and its 4th nearest neighbor in the stack MINDISTANCES2.  This
% will be used to normalize distances in each RBF-FD stencil (improving
% condition of the system we need to solve).

[nearidx mindistances] = knnsearch([xnodes ynodes],[xnodes ynodes],'k',2);
mindistances2 = mindistances(:,2).^2;

% the KNNSEARCH below generates another vector of distances - this time,
% they are distances to the FURTHEST neighbor of a stencil.  These
% will be used to normalize distances in polynomial evaluation.

[faridx maxdistance] = ...
    knnsearch([xnodes ynodes],[xnodes ynodes],'k',stencilsize);
normfactorint = maxdistance(:,stencilsize);

sparseip = [];   % initializing sparse indices
sparsejp = [];
sparseLp = [];

xpositionsInt = zeros(1,stencilsizeInt);
ypositionsInt = zeros(1,stencilsizeInt);
stencilZoneVec = zeros(1,stencilsizeInt);

xpositions = zeros(1,stencilsize); % within a periodic domain, we can't
ypositions = zeros(1,stencilsize); % simply use all the x- and y-
                                   % coordinates we have for every
xspan = xub-xlb;                   % stencil: some stencils will overlap
yspan = yub-ylb;                   % to the other side of the domain.
                                   % XPOSITIONS and YPOSITIONS and the
counter1 = 1;                      % loop below will help do this right.

rhoc2temp = 1;

tripleVec = zeros(N1,1);

for m = 1:(N1-2*numIntNodes)
    
    if ynodes(m,1) >= curvedinterface1(xnodes(m,1),yLI) && ynodes(m,1) <= curvedinterface2(xnodes(m,1),yUI)
        rhoc2temp = rho2*c2^2;
        rhoEval = rho2;
        rhoAcross = rho1;
    else
        rhoc2temp = rho1*c1^2;
        rhoEval = rho1;
        rhoAcross = rho2;
    end
    
    A = ones(stencilsize,stencilsize);  % For each RBF-FD
    RHS = zeros(stencilsize,1);         % stencil, we incorporate RBF info
                                        % from all the STENCILSIZE nearest
                                        % neighbors, as well as polynomial
                                        % info to be appended later.
    
    Aint = ones(stencilsizeInt,stencilsizeInt);
    RHSint = zeros(stencilsizeInt,1);            
    
    seqFlag = 0;
    %
    hApprox = 1/N1^0.5;
    if (abs(ynodes(m,1)-yLI) < queryFactor*hApprox) || (abs(ynodes(m,1)-yUI) < queryFactor*hApprox)
        seqFlag = 1;
    end
    %}
    
    if naiveFlag == 1
       tempidxstack = origidxstack(m,:);
       seqFlag = 0;
    else
       tempidxstack = origidxstackSeq1(m,:);
    end
    
    if seqFlag == 0
    
        for n = 1:stencilsize

            xpositions(1,n)=xnodes(tempidxstack(1,n),1);
            ypositions(1,n)=ynodes(tempidxstack(1,n),1);

            % Below, each node in every stencil is checked for the need to
            % "tile" or "ghost" that node to another part of the domain.  In
            % the future, this step could probably be incorporated into
            % FINDPERIODICNEIGHBORS6 for speed.

            if abs(xpositions(1,1)-(xpositions(1,n)+xspan))<...
                    abs(xpositions(1,1)-xpositions(1,n))
                xpositions(1,n)=xpositions(1,n)+xspan;
            end

            if abs(xpositions(1,1)-(xpositions(1,n)-xspan))<...
                    abs(xpositions(1,1)-xpositions(1,n))
                xpositions(1,n)=xpositions(1,n)-xspan;
            end

            if abs(ypositions(1,1)-(ypositions(1,n)+yspan))<...
                    abs(ypositions(1,1)-ypositions(1,n))
                ypositions(1,n)=ypositions(1,n)+yspan;
            end

            if abs(ypositions(1,1)-(ypositions(1,n)-yspan))<...
                    abs(ypositions(1,1)-ypositions(1,n))
                ypositions(1,n)=ypositions(1,n)-yspan;
            end
        end

        distmin2 = mindistances2(m,1);  % DISTMIN2 normalizes distances for
                                        % each RBF-FD stencil so we don't have
        % to choose optimal shape parameters for each stencil separately - with
        % this done and with IMQ RBFs, a uniform SHP of 0.2 works quite well.

        % the Laguerre polynomial, coefficient, and dimension of the space (2)
        % below will help evaluate the Laplacian of Gaussian RBFs, as described
        % in Fornberg and Lehto (2011).

        pk = zeros(Lk+1,1);                
        coeff = shp^(2*Lk)/(distmin2)^Lk;  
        d = 2;

        for i = 1:stencilsize        % creating the A matrix.
            for j = 1:stencilsize
                A(i,j) = ...
                    exp(-shp^2*...
                    ((xpositions(1,j)-xpositions(1,i))^2+...
                    (ypositions(1,j)-ypositions(1,i))^2)/distmin2);
            end

            % preparing to create the RHS.

            er2dbrmin2 = shp^2*((xpositions(1,1)-xpositions(1,i))^2+...
                    (ypositions(1,1)-ypositions(1,i))^2)/distmin2;
            pk(1,1) = 1;
            pk(2,1) = 4*er2dbrmin2-2*d;

            for k = 2:Lk
                pk(k+1,1) = 4*(er2dbrmin2-2*(k-1)-d/2)*pk(k,1)...
                    -8*(k-1)*(2*(k-1)-2+d)*pk(k-1,1);
            end

            % creating the RHS via Laguerre polynomial (Fornberg and Lehto,
            % 2011)

            RHS(i,1) = coeff*pk(Lk+1)*A(i,1);

        end

        % appending the A matrix with polynomials via AUGHYPERWITHPOLYS6

        hyperviscmatrixtemp = augLwithpolys1(A,RHS,xpositions,ypositions,...
            xpositions(1,1),ypositions(1,1),polydegree,1/normfactorint(m,1),Lk);

        % setting up indices and weights for sparse hyp. operator creation

        for n = 1:stencilsize
            sparseip(counter1,1) = m;
            sparsejp(counter1,1) = tempidxstack(1,n);
            sparseLp(counter1,1) = (-1)^(Lk+1)*hyperviscmatrixtemp(1,n);

            counter1 = counter1+1;
        end
    else
        
        tripleCheck = [0 0 0];
        
        for n = 1:stencilsizeInt
                        
            xpositionsInt(1,n)=xnodes(origidxstackInt(m,n),1);
            ypositionsInt(1,n)=ynodes(origidxstackInt(m,n),1);
            
            stencilZoneVec(1,n) = 1;
            
            if ypositionsInt(1,n) > curvedinterface1(xpositionsInt(1,n),yLI)
                stencilZoneVec(1,n) = 2;
                if ypositionsInt(1,n) > curvedinterface2(xpositionsInt(1,n),yUI)
                    stencilZoneVec(1,n) = 3;
                end
            end
            
            if stencilZoneVec(1,n) == 1
                tripleCheck(1,1) = 1;
            end
            if stencilZoneVec(1,n) == 2
                tripleCheck(1,2) = 1;
            end
            if stencilZoneVec(1,n) == 3
                tripleCheck(1,3) = 1;
            end
            
            % Below, each node in every stencil is checked for the need to
            % "tile" or "ghost" that node to another part of the domain.  In
            % the future, this step could probably be incorporated into
            % FINDPERIODICNEIGHBORS6 for speed.

            if abs(xpositionsInt(1,1)-(xpositionsInt(1,n)+xspan))<...
                    abs(xpositionsInt(1,1)-xpositionsInt(1,n))
                xpositionsInt(1,n)=xpositionsInt(1,n)+xspan;
            end

            if abs(xpositionsInt(1,1)-(xpositionsInt(1,n)-xspan))<...
                    abs(xpositionsInt(1,1)-xpositionsInt(1,n))
                xpositionsInt(1,n)=xpositionsInt(1,n)-xspan;
            end

            if abs(ypositionsInt(1,1)-(ypositionsInt(1,n)+yspan))<...
                    abs(ypositionsInt(1,1)-ypositionsInt(1,n))
                ypositionsInt(1,n)=ypositionsInt(1,n)+yspan;
            end

            if abs(ypositionsInt(1,1)-(ypositionsInt(1,n)-yspan))<...
                    abs(ypositionsInt(1,1)-ypositionsInt(1,n))
                ypositionsInt(1,n)=ypositionsInt(1,n)-yspan;
            end
            
        end
        
        tripleFlag = tripleCheck(1,1)*tripleCheck(1,3);
        
        tripleVec(m,1) = tripleFlag;
        
        evalZone = 1;
        
        if ypositionsInt(1,1) < (curvedinterface1(xpositionsInt(1,1),yLI)+curvedinterface2(xpositionsInt(1,1),yUI))/2
            [xClosest theta] = pointFinder1(xpositionsInt(1,1),ypositionsInt(1,1),yLI);           
            yClosest = curvedinterface1(xClosest,yLI);
            %yIntLoc = 0.25;
            if ypositionsInt(1,1) > curvedinterface1(xpositionsInt(1,1),yLI)
                evalZone = 2;
            end
        else
            [xClosest theta] = pointFinder2(xpositionsInt(1,1),ypositionsInt(1,1),yUI);   
            yClosest = curvedinterface2(xClosest,yUI);
            %yIntLoc = 0.5;
            
            evalZone = 3;
            
            if ypositionsInt(1,1) > curvedinterface2(xpositionsInt(1,1),yUI)
                evalZone = 4;
            end
        end
        
        xeval = xpositionsInt(1,1);
        yeval = ypositionsInt(1,1);
        
        Tpoints = [cos(theta) sin(theta); -sin(theta) cos(theta)];
        
        ypositionsIntWarp = ypositionsInt;
        zoneWidth = cos(theta)*(yUI-yLI);
        
        if tripleFlag == 0
            for n = 1:stencilsizeInt
                tempVec = Tpoints*[(xpositionsInt(1,n)-xClosest); (ypositionsInt(1,n)-yClosest)];
                %xpositionsInt(1,n) = (xpositionsInt(1,n)-xClosest);
                %ypositionsInt(1,n) = (ypositionsInt(1,n)-yClosest);
                xpositionsInt(1,n) = tempVec(1,1);
                ypositionsInt(1,n) = tempVec(2,1);
                if ((ypositionsInt(1,1)*ypositionsInt(1,n)) >= 0)
                    ypositionsIntWarp(1,n) = ypositionsInt(1,n);
                else
                    if RBFwarpFlag > 0
                        ypositionsIntWarp(1,n) = rhoEval/rhoAcross*ypositionsInt(1,n);
                    else
                        ypositionsIntWarp(1,n) = ypositionsInt(1,n);
                    end
                end
            end
        else
            for n = 1:stencilsizeInt
                tempVec = Tpoints*[(xpositionsInt(1,n)-xClosest); (ypositionsInt(1,n)-yClosest)];
                %xpositionsInt(1,n) = (xpositionsInt(1,n)-xClosest);
                %ypositionsInt(1,n) = (ypositionsInt(1,n)-yClosest);
                xpositionsInt(1,n) = tempVec(1,1);
                ypositionsInt(1,n) = tempVec(2,1);
                %ypositionsIntWarp(1,n) = ypositionsInt(1,n);
                %
                if RBFwarpFlag > 0
                    if evalZone == 1
                        if stencilZoneVec(1,n) == 2
                            ypositionsIntWarp(1,n) = rho1/rho2*ypositionsInt(1,n);
                        end
                        if stencilZoneVec(1,n) == 3
                            ypositionsIntWarp(1,n) = rho1/rho2*zoneWidth + ...
                                ypositionsInt(1,n)-zoneWidth;
                        end
                    end
                    if evalZone == 2
                        if stencilZoneVec(1,n) == 1
                            ypositionsIntWarp(1,n) = rho2/rho1*ypositionsInt(1,n);
                        end
                        if stencilZoneVec(1,n) == 3
                            ypositionsIntWarp(1,n) = zoneWidth + ...
                                (ypositionsInt(1,n)-zoneWidth)*rho2/rho1;
                        end
                    end
                    if evalZone == 3
                        if stencilZoneVec(1,n) == 1
                            ypositionsIntWarp(1,n) = -zoneWidth + ...
                                (ypositionsInt(1,n)+zoneWidth)*rho2/rho1;
                        end
                        if stencilZoneVec(1,n) == 3
                            ypositionsIntWarp(1,n) = rho2/rho1*ypositionsInt(1,n);
                        end
                    end
                    if evalZone == 4
                        if stencilZoneVec(1,n) == 2
                            ypositionsIntWarp(1,n) = rho1/rho2*ypositionsInt(1,n);
                        end
                        if stencilZoneVec(1,n) == 1
                            ypositionsIntWarp(1,n) = -rho1/rho2*zoneWidth + ...
                                ypositionsInt(1,n)+zoneWidth;
                        end
                    end
                end
                %}
            end
        end
        
        distmin2 = mindistances2(m,1);  % DISTMIN2 normalizes distances for
                                        % each RBF-FD stencil so we don't have
        % to choose optimal shape parameters for each stencil separately - with
        % this done and with IMQ RBFs, a uniform SHP of 0.2 works quite well.

        % the Laguerre polynomial, coefficient, and dimension of the space (2)
        % below will help evaluate the Laplacian of Gaussian RBFs, as described
        % in Fornberg and Lehto (2011).

        [c1Matrix c2Matrix c3Matrix c4Matrix nullMatrix1 nullMatrix2] = ...
            continuityCreator(xpositionsInt,ypositionsInt,...
            xeval,yeval,polydegreeInt,c1,rho1,c2,rho2,xClosest,Lk,yLI,yUI,tripleFlag,1/normfactorint(m,1),evalZone,zoneWidth);
        
        pk = zeros(Lk+1,1);
        
        coeff = shp^(2*Lk)/(distmin2)^Lk;  
        d = 2;

        for i = 1:stencilsizeInt        % creating the A matrix.
            for j = 1:stencilsizeInt
                Aint(i,j) = ...
                    exp(-shp^2*...
                    ((xpositionsInt(1,j)-xpositionsInt(1,i))^2+...
                    (ypositionsIntWarp(1,j)-ypositionsIntWarp(1,i))^2)/distmin2);
                
            end

            % preparing to create the RHS.

            er2dbrmin2 = shp^2*((xpositionsInt(1,1)-xpositionsInt(1,i))^2+...
                    (ypositionsIntWarp(1,1)-ypositionsIntWarp(1,i))^2)/distmin2;
            
            pk(1,1) = 1;
            pk(2,1) = 4*er2dbrmin2-2*d;

            for k = 2:Lk
                pk(k+1,1) = 4*(er2dbrmin2-2*(k-1)-d/2)*pk(k,1)...
                    -8*(k-1)*(2*(k-1)-2+d)*pk(k-1,1);
                
            end

            % creating the RHS via Laguerre polynomial (Fornberg and Lehto,
            % 2011)
            
            % row 1
            
            RHSint(i,1) = coeff*pk(Lk+1)*Aint(i,1);

        end
        
        Lweights = ...
            augLwithpolysInt1(Aint,RHSint,xpositionsInt,ypositionsInt,...
            xeval,yeval,polydegreeInt,1/normfactorint(m,1),...
            c1,rho1,c2,rho2,xClosest,Lk,c1Matrix,c2Matrix,c3Matrix,c4Matrix,...
            yLI,yUI,evalZone,stencilZoneVec,tripleFlag);
        
        %{
        Tbig = [(cos(theta))^2 2*sin(theta)*cos(theta) (sin(theta))^2; ...
            -sin(theta)*cos(theta) ((cos(theta))^2-(sin(theta))^2) sin(theta)*cos(theta); ...
            (sin(theta))^2 -2*sin(theta)*cos(theta) (cos(theta))^2];
        
        Tsmall = [cos(theta) sin(theta); -sin(theta) cos(theta)];
        %}
        
        % setting up indices and weights for sparse hyp. operator creation

        for n = 1:stencilsizeInt
            
            sparseip(counter1,1) = m;
            sparsejp(counter1,1) = origidxstackInt(m,n);
            sparseLp(counter1,1) = (-1)^(Lk+1)*Lweights(1,n);
            
            counter1 = counter1+1;
        end
    end
end

% and finally, creating the sparse RBF-FD hyperviscosity operator.

sparseLmatrix = sparse(sparseip,sparsejp,sparseLp,N1,N1);

%%% End function CREATERBFHYPOPERATORS6 %%%

end


function RBFFDweights = ...
    augLwithpolys1(A,RHS,xpositions,ypositions,xeval,yeval,...
    polydegree,normfactor,Lk)


numpolys = (polydegree+1)*(polydegree+2)/2;  % total number of terms added
n = size(A,1);                               % stencil size
augmatrix = zeros(n + numpolys);             % augmented (plus polys) matrix

augPblock = ones(n,numpolys);     % upper right and lower left blocks of LHS
augRHSblock = zeros(numpolys,1);   % additional vector for RHS (poly evals)

normfactor1 = normfactor;

xpositionsmod = normfactor1*(xpositions-xeval)'; % normalized x-coordinates
ypositionsmod = normfactor1*(ypositions-yeval)'; % normalized y-coordinates

counter1 = 0;   % counters help with poly evaluation
counter2 = 1;

for j = 2:numpolys    % here are the poly evaluations (at stencil nodes)
    
    augPblock(:,j)=xpositionsmod.^(counter2-counter1).*...
        ypositionsmod.^(counter1);

    counter1 = counter1+1;

    if counter1 > counter2
        counter1 = 0;
        counter2 = counter2+1;
    end

end

if Lk == 1
augRHSblock(4,1) = 2*normfactor1^2;
augRHSblock(6,1) = 2*normfactor1^2;
end

% building the augmented matrix...

augmatrix(1:n,1:n) = A;
augmatrix(1:n,(n+1):(n+numpolys)) = augPblock;
augmatrix((n+1):(n+numpolys),1:n) = augPblock';

newRHS = [RHS; augRHSblock];   % ...and augmented RHS

RBFFDweightstemp = (augmatrix\newRHS)';   % inverting...

RBFFDweights = RBFFDweightstemp(1,1:n);   % ...and truncating the weights.

%%% END function AUGHYPERWITHPOLYS6 %%%

end


function [c1Matrix c2Matrix c3Matrix c4Matrix nullMatrix1 nullMatrix2] = ...
    continuityCreator(xpositionsInt,ypositionsInt,xeval,yeval,...
    polydegreeInt,c1,rho1,c2,rho2,xClosest,Lk,yLI,yUI,tripleFlag,normfactor,evalZone,zoneWidth)

numpolys = (polydegreeInt+1)*(polydegreeInt+2)/2;  % total number of terms added

% posInd gives us which side of which interface we're on.

dxBlock = zeros(numpolys);
dyBlock = dxBlock;

dxBlock(2,1) = 1;
dyBlock(3,1) = 1;

intLoc1 = 0;
intLoc2 = 0;

if tripleFlag > 0
    if (evalZone == 1) || (evalZone == 2)
        intLoc2 = normfactor*zoneWidth;
    end
    if (evalZone == 3) || (evalZone == 4)
        intLoc1 = -normfactor*zoneWidth;
    end
end

xPower = []; yPower = [];

for k = 0:polydegreeInt
   yPower = [yPower; (0:k)'];
   xPower = [xPower; (k:-1:0)'];
end

for k = 2:polydegreeInt
    startIndexi = (k*(k+1))/2+1;
    finalIndexi = ((k+1)*(k+2))/2;
    
    startIndexj = ((k-1)*k)/2+1;
    finalIndexj = (k*(k+1))/2;
    
    dxBlock(startIndexi:startIndexi+(k-1),startIndexj:finalIndexj) = ...
        diag(fliplr(1:k));
    dyBlock(startIndexi+1:finalIndexi,startIndexj:finalIndexj) = ...
        diag(1:k);
end
%

nullMatrix1 = [];
nullMatrix2 = [];

blockSize = size(dxBlock,1);
zeroBlock = zeros(blockSize);

dxBlock = dxBlock';
dyBlock = dyBlock';

rhoc2LowerTemp = rho1*c1^2;
rhoc2UpperTemp = rho2*c2^2;
rhoLowerTemp = rho1;
rhoUpperTemp = rho2;

bigOp1 = rhoLowerTemp*(dxBlock*dxBlock+dyBlock*dyBlock);
bigOp2 = rhoUpperTemp*(dxBlock*dxBlock+dyBlock*dyBlock);
secondOp1 = rhoLowerTemp*dyBlock;
secondOp2 = rhoUpperTemp*dyBlock;

rowCounter = 1;

% lower equivalence

for opPowerCounter = 0:polydegreeInt
    
    polyLimit = polydegreeInt-opPowerCounter;
    polyLimNo = (polyLimit+1)*(polyLimit+2)/2;
    
    if mod(opPowerCounter,2) == 0
        tempOp1 = bigOp1^(opPowerCounter/2);
        tempOp2 = -bigOp2^(opPowerCounter/2);
        
        tempStack = [tempOp1 tempOp2];
        
        for k1 = 1:numpolys
            if yPower(k1,1) > 0
                for k2 = 1:numpolys
                    if (xPower(k2,1) == xPower(k1,1)) && (yPower(k2,1) == 0)
                        tempStack(k2,:) = tempStack(k2,:)+tempStack(k1,:)*intLoc1^yPower(k1,1);
                    end
                end
            end
        end
        
        colCounter = 1;
        advCounter = 1;
        for k = 0:polydegreeInt-opPowerCounter
            nullMatrix1(rowCounter,:) = tempStack(colCounter,:);
            colCounter = colCounter+advCounter;
            advCounter = advCounter+1;
            rowCounter = rowCounter+1;
        end
    else
        %{
        tempStack = [tempOp1(1+0*blockSize:1*blockSize,1+2*blockSize:3*blockSize); ...
            tempOp2(1+0*blockSize:1*blockSize,1+2*blockSize:3*blockSize)];
        colCounter = 1;
        advCounter = 1;
        for k = 0:polydegreeInt-opPowerCounter
            nullMatrix(rowCounter,:) = tempStack(:,colCounter)';
            colCounter = colCounter+advCounter;
            advCounter = advCounter+1;
            rowCounter = rowCounter+1;
        end
        %}
        %
        tempOp1 = secondOp1*bigOp1^((opPowerCounter-1)/2);
        tempOp2 = -secondOp2*bigOp2^((opPowerCounter-1)/2);
        
        tempStack = [tempOp1 tempOp2];
        
        for k1 = 1:numpolys
            if yPower(k1,1) > 0
                for k2 = 1:numpolys
                    if (xPower(k2,1) == xPower(k1,1)) && (yPower(k2,1) == 0)
                        tempStack(k2,:) = tempStack(k2,:)+tempStack(k1,:)*intLoc1^yPower(k1,1);
                    end
                end
            end
        end
        
        colCounter = 1;
        advCounter = 1;
        for k = 0:polydegreeInt-opPowerCounter
            nullMatrix1(rowCounter,:) = tempStack(colCounter,:);
            colCounter = colCounter+advCounter;
            advCounter = advCounter+1;
            rowCounter = rowCounter+1;
        end
        %}
    end
end

rhoc2LowerTemp = rho2*c2^2;
rhoc2UpperTemp = rho1*c1^2;
rhoLowerTemp = rho2;
rhoUpperTemp = rho1;

bigOp1 = rhoLowerTemp*(dxBlock*dxBlock+dyBlock*dyBlock);
bigOp2 = rhoUpperTemp*(dxBlock*dxBlock+dyBlock*dyBlock);
secondOp1 = rhoLowerTemp*dyBlock;
secondOp2 = rhoUpperTemp*dyBlock;

rowCounter = 1;

% upper equivalence

for opPowerCounter = 0:polydegreeInt
    
    if mod(opPowerCounter,2) == 0
        tempOp1 = bigOp1^(opPowerCounter/2);
        tempOp2 = -bigOp2^(opPowerCounter/2);
        tempStack = [tempOp1 tempOp2];
        
        for k1 = 1:numpolys
            if yPower(k1,1) > 0
                for k2 = 1:numpolys
                    if (xPower(k2,1) == xPower(k1,1)) && (yPower(k2,1) == 0)
                        tempStack(k2,:) = tempStack(k2,:)+tempStack(k1,:)*intLoc2^yPower(k1,1);
                    end
                end
            end
        end
        
        colCounter = 1;
        advCounter = 1;
        for k = 0:polydegreeInt-opPowerCounter
            nullMatrix2(rowCounter,:) = tempStack(colCounter,:);
            colCounter = colCounter+advCounter;
            advCounter = advCounter+1;
            rowCounter = rowCounter+1;
        end
    else
        %{
        tempStack = [tempOp1(1+0*blockSize:1*blockSize,1+2*blockSize:3*blockSize); ...
            tempOp2(1+0*blockSize:1*blockSize,1+2*blockSize:3*blockSize)];
        colCounter = 1;
        advCounter = 1;
        for k = 0:polydegreeInt-opPowerCounter
            nullMatrix(rowCounter,:) = tempStack(:,colCounter)';
            colCounter = colCounter+advCounter;
            advCounter = advCounter+1;
            rowCounter = rowCounter+1;
        end
        %}
        %
        
        tempOp1 = secondOp1*bigOp1^((opPowerCounter-1)/2);
        tempOp2 = -secondOp2*bigOp2^((opPowerCounter-1)/2);
        
        tempStack = [tempOp1 tempOp2];
        
        for k1 = 1:numpolys
            if yPower(k1,1) > 0
                for k2 = 1:numpolys
                    if (xPower(k2,1) == xPower(k1,1)) && (yPower(k2,1) == 0)
                        tempStack(k2,:) = tempStack(k2,:)+tempStack(k1,:)*intLoc2^yPower(k1,1);
                    end
                end
            end
        end
        
        colCounter = 1;
        advCounter = 1;
        for k = 0:polydegreeInt-opPowerCounter
            nullMatrix2(rowCounter,:) = tempStack(colCounter,:);
            colCounter = colCounter+advCounter;
            advCounter = advCounter+1;
            rowCounter = rowCounter+1;
        end
        %}
    end
end

for k = 1:numpolys
    nullMatrix1(k,:) = nullMatrix1(k,:)/max(abs(nullMatrix1(k,:)));
    nullMatrix2(k,:) = nullMatrix2(k,:)/max(abs(nullMatrix2(k,:)));
end

c1Matrix = nullMatrix1(1:numpolys,1:numpolys);
c2Matrix = -nullMatrix1(1:numpolys,1+numpolys:2*numpolys);

c3Matrix = nullMatrix2(1:numpolys,1:numpolys);
c4Matrix = -nullMatrix2(1:numpolys,1+numpolys:2*numpolys);

%%% END function continuityCreator %%%

end

function Lweights = ...
    augLwithpolysInt1(A,RHS,xpositionsInt,ypositionsInt,xeval,yeval,...
    polydegreeInt,normfactor,c1,rho1,c2,rho2,xClosest,Lk,c1Matrix,c2Matrix,c3Matrix,c4Matrix,...
    yLI,yUI,evalZone,stencilZoneVec,tripleFlag)

normfactor1 = normfactor;

numpolys = (polydegreeInt+1)*(polydegreeInt+2)/2;  % total number of terms added
n = size(A,1);                               % stencil size (total both sides)

% posInd gives us which side of which interface we're on.

rhoc2LowerTemp = rho1*c1^2;
rhoc2UpperTemp = rho2*c2^2;
rhoLowerTemp = rho1;
rhoUpperTemp = rho2;

if yeval > (curvedinterface1(xeval,yLI)+curvedinterface2(xeval,yUI))/2
    rhoc2LowerTemp = rho2*c2^2;
    rhoc2UpperTemp = rho1*c1^2;
    rhoLowerTemp = rho2;
    rhoUpperTemp = rho1;
end

xpositionsmod = normfactor1*(xpositionsInt)'; % normalized x-coordinates
upperEvalFlag = 0;
%
if yeval < (curvedinterface1(xeval,yLI)+curvedinterface2(xeval,yUI))/2
    ypositionsmod = normfactor1*(ypositionsInt)';
    if yeval > curvedinterface1(xeval,yLI)
        upperEvalFlag = 1;
    end
                                        % normalized y-coordinates
else                                               % (to nearest int.)
    ypositionsmod = normfactor1*(ypositionsInt)';
    if yeval > curvedinterface2(xeval,yUI)
        upperEvalFlag = 1;
    end
end
%}

%%% HERE'S THE BIG CHANGE

%pFuncs = null(nullMatrix);

% START HERE EDIT 10

pFuncs = zeros(3*numpolys,numpolys);
pFuncs(1+numpolys:2*numpolys,1:numpolys) = eye(numpolys);

pFuncs(1:numpolys,1:numpolys) = c1Matrix\c2Matrix;
pFuncs(1+2*numpolys:3*numpolys,1:numpolys) = c4Matrix\c3Matrix;

xCoefInd = [];
yCoefInd = [];

for k3 = 0:polydegreeInt
   yCoefInd = [yCoefInd; (0:k3)'];
   xCoefInd = [xCoefInd; (k3:-1:0)'];
end


%
for m = 1:n
    
    if stencilZoneVec(1,m) == 1
        
    % defining polys - below interface zone
        
        for z = 1:size(pFuncs,2)
            
            preAugPblock(m,z) = 0;
     
            % p (lower)
            for k1 = 1:numpolys
                
                preAugPblock(m,z)=preAugPblock(m,z)+...
                    pFuncs(k1,z)*xpositionsmod(m,1)^xCoefInd(k1,1)*ypositionsmod(m,1)^yCoefInd(k1,1);

            end
        end
        
    end
    
    % defining polys - mid zone    
        
    if stencilZoneVec(1,m) == 2
        
        for z = 1:size(pFuncs,2)
            
            preAugPblock(m,z) = 0;
            
            % p (upper)
            for k1 = 1:numpolys
                preAugPblock(m,z)=preAugPblock(m,z)+...
                    pFuncs(k1+1*numpolys,z)*xpositionsmod(m,1)^xCoefInd(k1,1)*ypositionsmod(m,1)^yCoefInd(k1,1);        
            end
        end
        
    end
    
    % defining polys - top zone    
        
    if stencilZoneVec(1,m) == 3
        
        for z = 1:size(pFuncs,2)
            
            preAugPblock(m,z) = 0;
            
            % p (upper)
            for k1 = 1:numpolys
                preAugPblock(m,z)=preAugPblock(m,z)+...
                    pFuncs(k1+2*numpolys,z)*xpositionsmod(m,1)^xCoefInd(k1,1)*ypositionsmod(m,1)^yCoefInd(k1,1);        
            end
        end
        
    end
end

preAugRHSblock = zeros(size(preAugPblock,2),1);

xCoef2Der = xCoefInd.*(xCoefInd-1);
yCoef2Der = yCoefInd.*(yCoefInd-1);
if Lk == 1
    if evalZone == 1

        for z = 1:size(pFuncs,2)

            % p (upper)
            for k1 = 1:numpolys
                if xCoef2Der(k1,1) ~= 0
                    preAugRHSblock(z,1)=preAugRHSblock(z,1)+...
                        normfactor1^2*xCoef2Der(k1,1)*pFuncs(k1,z)*xpositionsmod(1,1)^(xCoefInd(k1,1)-2)*ypositionsmod(1,1)^yCoefInd(k1,1);
                end
                if yCoef2Der(k1,1) ~= 0
                    preAugRHSblock(z,1)=preAugRHSblock(z,1)+...
                        normfactor1^2*yCoef2Der(k1,1)*pFuncs(k1,z)*xpositionsmod(1,1)^xCoefInd(k1,1)*ypositionsmod(1,1)^(yCoefInd(k1,1)-2);
                end
            end
        end

    end
    
    if (evalZone == 2) || (evalZone == 3)
        for z = 1:size(pFuncs,2)

            % p (upper)
            for k1 = 1:numpolys
                if xCoef2Der(k1,1) ~= 0
                    preAugRHSblock(z,1)=preAugRHSblock(z,1)+...
                        normfactor1^2*xCoef2Der(k1,1)*pFuncs(k1+numpolys,z)*xpositionsmod(1,1)^(xCoefInd(k1,1)-2)*ypositionsmod(1,1)^yCoefInd(k1,1);
                end
                if yCoef2Der(k1,1) ~= 0
                    preAugRHSblock(z,1)=preAugRHSblock(z,1)+...
                        normfactor1^2*yCoef2Der(k1,1)*pFuncs(k1+numpolys,z)*xpositionsmod(1,1)^xCoefInd(k1,1)*ypositionsmod(1,1)^(yCoefInd(k1,1)-2);
                end
            end
        end
    end
    
    if evalZone == 4
        for z = 1:size(pFuncs,2)

            % p (upper)
            for k1 = 1:numpolys
                if xCoef2Der(k1,1) ~= 0
                    preAugRHSblock(z,1)=preAugRHSblock(z,1)+...
                        normfactor1^2*xCoef2Der(k1,1)*pFuncs(k1+2*numpolys,z)*xpositionsmod(1,1)^(xCoefInd(k1,1)-2)*ypositionsmod(1,1)^yCoefInd(k1,1);
                end
                if yCoef2Der(k1,1) ~= 0
                    preAugRHSblock(z,1)=preAugRHSblock(z,1)+...
                        normfactor1^2*yCoef2Der(k1,1)*pFuncs(k1+2*numpolys,z)*xpositionsmod(1,1)^xCoefInd(k1,1)*ypositionsmod(1,1)^(yCoefInd(k1,1)-2);
                end
            end
        end
    end
end
% building the augmented matrices...

augAmatrix = [A preAugPblock; ...
    preAugPblock' zeros(size(preAugPblock,2))];

% storing weights

newRHS = [RHS; preAugRHSblock];

RBFFDweightstemp = (augAmatrix\newRHS)'; 
Lweights = RBFFDweightstemp(1,1:n);

%%% END function AUGHYPERWITHPOLYSINT2 %%%

end

function [origidxstack distances] = ...
    findperiodicneighbors6(oldxnodes, oldynodes, newxnodes, newynodes, ...
    xlb, xub, ylb, yub, stencilsize)

% FINDPERIODICNEIGHBORS6 is a "tiling" method for finding periodic nearest
% neighbors of each RBF node (NEWNODES) within 
% SOME set of RBF nodes (OLDNODES)  in a periodic square - which makes it useful for local RBF 
% interpolation during dynamic node refinement (or other applications).

% INPUTS:

% oldxnodes: (N1,1) vector of x-coordinates for RBF-FD nodes.  Neighbors
%            for all NEWNODES will be found from within THIS set (paired 
%            with OLDYNODES).
% oldynodes: Same as above, for OLD y-coordinates
% newxnodes: (N2,1) vector of NEW x-coordinates.  Neighbors for each of
%            these will be found from within OLDNODES.
% newynodes: Same as above, for NEW y-coordinates
% xlb, etc.: lower and upper bounds for the problem domain in x and y
% stencilsize: # of nearest neighbors to find for a node in the domain
%              (including that node itself, if it's in the set!)

% OUTPUTS:

% origidxstack: a matrix of indices of the STENCILSIZE nearest neighbors 
%               in OLDNODES (columns) to each of the N2 NEW RBF-FD nodes 
%               (rows).  These indices point to the nearest neighbors as 
%               seen in the ORIGINAL (OLD) set of RBF-nodes
% distances:    stack of Euclidean distances that corresponds to the
%               nearest-neighbor matchings in ORIGIDXSTACK above

%%% Begin function FINDPERIODICNEIGHBORS6 %%%

% First, average distance to the "STENCILSIZE"th nearest neighbor is found
% for 20 random RBF-FD nodes...

[testidx testdist] = ...
    knnsearch([oldxnodes oldynodes],...
    [oldxnodes(1:20,1) oldynodes(1:20,1)],'k',stencilsize);

avgdist = sum(testdist(:,size(testdist,2)))/size(testdist,1);

safedist = 2*avgdist;   % ... then, this distance is doubled...

xspan = xub-xlb;        % ... and below, if nodes are located within this
yspan = yub-ylb;        % "safedist" of the domain boundary, they are
                        % "ghosted" or "replicated on the other side of
xoverlap = [];          % the periodic domain so that the subsequent
yoverlap = [];          % KNNSEARCH produces the correct identity of
origidx = [];           % nearest neighbors for each node.
counter = 1;

for m = 1:size(oldxnodes,1)
    
    if xub-oldxnodes(m,1)<=safedist
        xoverlap(counter,1)=oldxnodes(m,1)-xspan;
        yoverlap(counter,1)=oldynodes(m,1);
        origidx(counter,1) = m;
        counter = counter+1;
    end
    
    if oldxnodes(m,1)-xlb<=safedist
        xoverlap(counter,1)=oldxnodes(m,1)+xspan;
        yoverlap(counter,1)=oldynodes(m,1);
        origidx(counter,1) = m;
        counter = counter+1;
    end
    %{
    if yub-oldynodes(m,1)<=safedist
        yoverlap(counter,1)=oldynodes(m,1)-yspan;
        xoverlap(counter,1)=oldxnodes(m,1);
        origidx(counter,1) = m;
        counter = counter+1;
    end
    
    if oldynodes(m,1)-ylb<=safedist
        yoverlap(counter,1)=oldynodes(m,1)+yspan;
        xoverlap(counter,1)=oldxnodes(m,1);
        origidx(counter,1) = m;
        counter = counter+1;
    end
    
    if xub-oldxnodes(m,1)<=safedist
        if yub-oldynodes(m,1)<=safedist
        xoverlap(counter,1)=oldxnodes(m,1)-xspan;
        yoverlap(counter,1)=oldynodes(m,1)-yspan;
        origidx(counter,1) = m;
        counter = counter+1;
        end
    end
    
    if xub-oldxnodes(m,1)<=safedist
        if oldynodes(m,1)-ylb<=safedist
        xoverlap(counter,1)=oldxnodes(m,1)-xspan;
        yoverlap(counter,1)=oldynodes(m,1)+yspan;
        origidx(counter,1) = m;
        counter = counter+1;
        end
    end
    
    if oldxnodes(m,1)-xlb<=safedist
        if yub-oldynodes(m,1)<=safedist
        xoverlap(counter,1)=oldxnodes(m,1)+xspan;
        yoverlap(counter,1)=oldynodes(m,1)+yspan;
        origidx(counter,1) = m;
        counter = counter+1;
        end
    end
    
    if oldxnodes(m,1)-xlb<=safedist
        if oldynodes(m,1)-ylb<=safedist
        xoverlap(counter,1)=oldxnodes(m,1)+xspan;
        yoverlap(counter,1)=oldynodes(m,1)-yspan;
        origidx(counter,1) = m;
        counter = counter+1;
        end
    end
    %}
end

xaug = [oldxnodes; xoverlap];                % xaug and yaug hold the x-
yaug = [oldynodes; yoverlap];                % and y-coordinates of both
origidx = [(1:size(oldxnodes,1))'; origidx]; % the original and "tiled"
                                             % OLD RBF-FD nodes.
                                             
% ...now we search within this augmented list of both original and "tiled"
% nodes to find the appropriate, periodic nearest neighbors...                                             

[idxtemp distances] = knnsearch([xaug yaug],[newxnodes newynodes],...
    'k',stencilsize);

origidxstack = zeros(size(idxtemp));

for m = 1:size(idxtemp,1)                      % ...and finally we create
    for n = 1:size(idxtemp,2)                       % a stack of original
        origidxstack(m,n)=origidx(idxtemp(m,n),1);  % indices for the
    end                                             % STENCILSIZE nearest
end                                                 % neighbors (columns)
                               % to each RBF-FD node in the domain (rows).

%%% End function FINDPERIODICNEIGHBORS6 %%%
                               
end


function [origidxstack origidxstack2 distances1 distances2] = ...
    findperiodicneighborsSeq1(oldxnodes, oldynodes, newxnodes, newynodes, ...
    xlb, xub, ylb, yub, stencilsize, seqVec1, seqVec2)

% this is a modification of the routine described below -
% meant for limiting stencils to one side of an interface.

% FINDPERIODICNEIGHBORS6 is a "tiling" method for finding periodic nearest
% neighbors of each RBF node (NEWNODES) within 
% SOME set of RBF nodes (OLDNODES)  in a periodic square - which makes it useful for local RBF 
% interpolation during dynamic node refinement (or other applications).

% INPUTS:

% oldxnodes: (N1,1) vector of x-coordinates for RBF-FD nodes.  Neighbors
%            for all NEWNODES will be found from within THIS set (paired 
%            with OLDYNODES).
% oldynodes: Same as above, for OLD y-coordinates
% newxnodes: (N2,1) vector of NEW x-coordinates.  Neighbors for each of
%            these will be found from within OLDNODES.
% newynodes: Same as above, for NEW y-coordinates
% xlb, etc.: lower and upper bounds for the problem domain in x and y
% stencilsize: # of nearest neighbors to find for a node in the domain
%              (including that node itself, if it's in the set!)

% OUTPUTS:

% origidxstack: a matrix of indices of the STENCILSIZE nearest neighbors 
%               in OLDNODES (columns) to each of the N2 NEW RBF-FD nodes 
%               (rows).  These indices point to the nearest neighbors as 
%               seen in the ORIGINAL (OLD) set of RBF-nodes
% distances:    stack of Euclidean distances that corresponds to the
%               nearest-neighbor matchings in ORIGIDXSTACK above

%%% Begin function FINDPERIODICNEIGHBORS6 %%%

% First, average distance to the "STENCILSIZE"th nearest neighbor is found
% for 20 random RBF-FD nodes...

[testidx testdist] = ...
    knnsearch([oldxnodes oldynodes],...
    [oldxnodes(1:20,1) oldynodes(1:20,1)],'k',stencilsize);

avgdist = sum(testdist(:,size(testdist,2)))/size(testdist,1);

safedist = 2*avgdist;   % ... then, this distance is doubled...

xspan = xub-xlb;        % ... and below, if nodes are located within this
yspan = yub-ylb;        % "safedist" of the domain boundary, they are
                        % "ghosted" or "replicated on the other side of
xoverlap = [];          % the periodic domain so that the subsequent
yoverlap = [];          % KNNSEARCH produces the correct identity of
origidx = [];           % nearest neighbors for each node.
seqVec1overlap = [];
seqVec2overlap = [];
counter = 1;

for m = 1:size(oldxnodes,1)
    
    if xub-oldxnodes(m,1)<=safedist
        xoverlap(counter,1)=oldxnodes(m,1)-xspan;
        yoverlap(counter,1)=oldynodes(m,1);
        origidx(counter,1) = m;
        seqVec1overlap(counter,1) = seqVec1(m,1);
        seqVec2overlap(counter,1) = seqVec2(m,1);
        counter = counter+1;
    end
    
    if oldxnodes(m,1)-xlb<=safedist
        xoverlap(counter,1)=oldxnodes(m,1)+xspan;
        yoverlap(counter,1)=oldynodes(m,1);
        origidx(counter,1) = m;
        seqVec1overlap(counter,1) = seqVec1(m,1);
        seqVec2overlap(counter,1) = seqVec2(m,1);
        counter = counter+1;
    end
    %{
    if yub-oldynodes(m,1)<=safedist
        yoverlap(counter,1)=oldynodes(m,1)-yspan;
        xoverlap(counter,1)=oldxnodes(m,1);
        origidx(counter,1) = m;
        seqVec1overlap(counter,1) = seqVec1(m,1);
        seqVec2overlap(counter,1) = seqVec2(m,1);
        counter = counter+1;
    end
    
    if oldynodes(m,1)-ylb<=safedist
        yoverlap(counter,1)=oldynodes(m,1)+yspan;
        xoverlap(counter,1)=oldxnodes(m,1);
        origidx(counter,1) = m;
        seqVec1overlap(counter,1) = seqVec1(m,1);
        seqVec2overlap(counter,1) = seqVec2(m,1);
        counter = counter+1;
    end
    
    if xub-oldxnodes(m,1)<=safedist
        if yub-oldynodes(m,1)<=safedist
        xoverlap(counter,1)=oldxnodes(m,1)-xspan;
        yoverlap(counter,1)=oldynodes(m,1)-yspan;
        origidx(counter,1) = m;
        seqVec1overlap(counter,1) = seqVec1(m,1);
        seqVec2overlap(counter,1) = seqVec2(m,1);
        counter = counter+1;
        end
    end
    
    if xub-oldxnodes(m,1)<=safedist
        if oldynodes(m,1)-ylb<=safedist
        xoverlap(counter,1)=oldxnodes(m,1)-xspan;
        yoverlap(counter,1)=oldynodes(m,1)+yspan;
        origidx(counter,1) = m;
        seqVec1overlap(counter,1) = seqVec1(m,1);
        seqVec2overlap(counter,1) = seqVec2(m,1);
        counter = counter+1;
        end
    end
    
    if oldxnodes(m,1)-xlb<=safedist
        if yub-oldynodes(m,1)<=safedist
        xoverlap(counter,1)=oldxnodes(m,1)+xspan;
        yoverlap(counter,1)=oldynodes(m,1)+yspan;
        origidx(counter,1) = m;
        seqVec1overlap(counter,1) = seqVec1(m,1);
        seqVec2overlap(counter,1) = seqVec2(m,1);
        counter = counter+1;
        end
    end
    
    if oldxnodes(m,1)-xlb<=safedist
        if oldynodes(m,1)-ylb<=safedist
        xoverlap(counter,1)=oldxnodes(m,1)+xspan;
        yoverlap(counter,1)=oldynodes(m,1)-yspan;
        origidx(counter,1) = m;
        seqVec1overlap(counter,1) = seqVec1(m,1);
        seqVec2overlap(counter,1) = seqVec2(m,1);
        counter = counter+1;
        end
    end
    %}
end

xaug = [oldxnodes; xoverlap];                % xaug and yaug hold the x-
yaug = [oldynodes; yoverlap];                % and y-coordinates of both
origidx = [(1:size(oldxnodes,1))'; origidx]; % the original and "tiled"
                                             % OLD RBF-FD nodes.
seqVec1aug = [seqVec1; seqVec1overlap];
seqVec2aug = [seqVec2; seqVec2overlap];

isolateVec1 = 4*seqVec2aug;
isolateVec2 = 4*seqVec1aug;

% ...now we search within this augmented list of both original and "tiled"
% nodes to find the appropriate, periodic nearest neighbors...                                             

[idxtemp1 distances1] = knnsearch([xaug+isolateVec1 yaug],...
    [newxnodes newynodes],...
    'k',stencilsize);

[idxtemp2 distances2] = knnsearch([xaug+isolateVec2 yaug],...
    [newxnodes newynodes],...
    'k',stencilsize);

origidxstack = zeros(size(idxtemp1));
origidxstack2 = zeros(size(idxtemp1));

for m = 1:size(idxtemp1,1)                      % ...and finally we create
    for n = 1:size(idxtemp1,2)                  % a stack of original
        if seqVec1(m,1) == 1
            origidxstack(m,n)=origidx(idxtemp1(m,n),1);
            origidxstack2(m,n)=origidx(idxtemp2(m,n),1);
        else
            origidxstack(m,n)=origidx(idxtemp2(m,n),1);
            origidxstack2(m,n)=origidx(idxtemp1(m,n),1);
        end
        % indices for the
    end                                             % STENCILSIZE nearest
end                                                 % neighbors (columns)
                               % to each RBF-FD node in the domain (rows).

%%% End function FINDPERIODICNEIGHBORS6 %%%
                               
end


function sparseblockmatrix = sparseblockmaker(origmatrix,rowindex,colindex,blockrowscols)

% function SPARSEBLOCKMAKER creates a big square block matrix (sparse) with
% a smaller square block matrix (origmatrix) as its only nonzero block.
% One can call this function a number of times to efficiently create a
% big, sparse block matrix.

% IN:

% origmatrix: original sparse matrix
% rowindex: the block row index that ORIGMATRIX will occupy in the sparse block
% matrix
% colindex: the block col index that ORIGMATRIX will occupy in the sparse
% block matrix
% blockrowscols: number of block rows and columns in the sparse block
% matrix

% OUT:

% sparseblockmatrix: sparse block matrix including origmatrix as one block.

%%% Begin function sparseblockmatrix %%%

Norig = size(origmatrix,1);           % size of original matrix (square)
Nnew = Norig*blockrowscols;           % size of new big matrix
onesvec = ones(size(origmatrix,1),1); % used to place orig. matrix in the
indexvec = (1:Norig)';                % correct block

% below, leftmatrix and rightmatrix left- and right-multiply the original
% matrix to create the new sparse block matrix.

leftmatrix = sparse(indexvec+(rowindex-1)*Norig,indexvec,onesvec,Nnew,Norig);
rightmatrix = sparse(indexvec,indexvec+(colindex-1)*Norig,onesvec,Norig,Nnew);

sparseblockmatrix = leftmatrix*origmatrix*rightmatrix;

%%% End function sparseblockmatrix %%%

end

function [xClosest theta] = pointFinder1(x,y,yLI)
    
    %xClosest = x; theta = 0;

    xClosest = []; yClosest = [];
    
    xClosest = [xClosest; x]; yClosest = [yClosest; curvedinterface1(x,yLI)];
    theta = []; theta = [theta; 0];
    
    for k = 2:20
        [yeval yprime] = curvedinterface1(xClosest(k-1,1),yLI);
        
        b = yeval-yprime*xClosest(k-1,1);
        
        theta = atan(yprime);
        
        transform = [cos(theta) sin(theta); -sin(theta) cos(theta)];
        invTransf = [cos(theta) -sin(theta); sin(theta) cos(theta)];
        
        newVec1 = transform*([x; y-b]);
        newVec2 = [newVec1(1,1); 0];
        newVec3 = invTransf*newVec2 + [0; b];
        
        xClosest = [xClosest; newVec3(1,1)];
        yClosest = [yClosest; curvedinterface1(newVec3(1,1),yLI)];  
    end
    xClosest = newVec3(1,1);
end

function [xClosest theta] = pointFinder2(x,y,yUI)
    %xClosest = x; theta = 0;
    xClosest = []; yClosest = [];
    
    xClosest = [xClosest; x]; yClosest = [yClosest; curvedinterface2(x,yUI)];
    theta = []; theta = [theta; 0];
    
    for k = 2:20
        [yeval yprime] = curvedinterface2(xClosest(k-1,1),yUI);
        
        b = yeval-yprime*xClosest(k-1,1);
        
        theta = atan(yprime);
        
        transform = [cos(theta) sin(theta); -sin(theta) cos(theta)];
        invTransf = [cos(theta) -sin(theta); sin(theta) cos(theta)];
        
        newVec1 = transform*([x; y-b]);
        newVec2 = [newVec1(1,1); 0];
        newVec3 = invTransf*newVec2 + [0; b];
        
        xClosest = [xClosest; newVec3(1,1)];
        yClosest = [yClosest; curvedinterface2(newVec3(1,1),yUI)];  
    end
    xClosest = newVec3(1,1);
end