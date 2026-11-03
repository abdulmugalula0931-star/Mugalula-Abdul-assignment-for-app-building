function NumericalMethodsApp
% NUMERICALMETHODSAPP
% Interactive MATLAB app for the Group Five Numerical Methods assignment.
% Methods: Newton-Raphson, Secant and fourth-order Runge-Kutta (RK4).
% Each method can be run with either a FOR loop or a WHILE loop.
%
% Save this file as NumericalMethodsApp.m and run:
% >> NumericalMethodsApp

    fig = uifigure('Name','Numerical Methods App - Group Five', ...
        'Position',[100 80 1100 700]);

    main = uigridlayout(fig,[2 2]);
    main.RowHeight = {220,'1x'};
    main.ColumnWidth = {330,'1x'};
    main.Padding = [12 12 12 12];
    main.RowSpacing = 10;
    main.ColumnSpacing = 10;

    % Input panel
    inputPanel = uipanel(main,'Title','Method and input values');
    inputPanel.Layout.Row = 1;
    inputPanel.Layout.Column = 1;
    g = uigridlayout(inputPanel,[8 2]);
    g.RowHeight = {23,23,23,23,23,23,23,28};
    g.ColumnWidth = {125,'1x'};
    g.Padding = [8 8 8 8];

    uilabel(g,'Text','Numerical method:');
    methodDrop = uidropdown(g,'Items',{'Newton-Raphson','Secant','Runge-Kutta RK4'});
    methodDrop.Layout.Row = 1; methodDrop.Layout.Column = 2;

    lbl = uilabel(g,'Text','Loop type:'); lbl.Layout.Row = 2; lbl.Layout.Column = 1;
    loopDrop = uidropdown(g,'Items',{'FOR loop','WHILE loop'});
    loopDrop.Layout.Row = 2; loopDrop.Layout.Column = 2;

    lbl = uilabel(g,'Text','Initial x / x0:'); lbl.Layout.Row = 3; lbl.Layout.Column = 1;
    x0Field = uieditfield(g,'numeric','Value',1.5);
    x0Field.Layout.Row = 3; x0Field.Layout.Column = 2;

    lbl = uilabel(g,'Text','Second x (Secant):'); lbl.Layout.Row = 4; lbl.Layout.Column = 1;
    x1Field = uieditfield(g,'numeric','Value',2);
    x1Field.Layout.Row = 4; x1Field.Layout.Column = 2;

    lbl = uilabel(g,'Text','Tolerance / step h:'); lbl.Layout.Row = 5; lbl.Layout.Column = 1;
    tolField = uieditfield(g,'numeric','Value',0.0001,'Limits',[eps Inf]);
    tolField.Layout.Row = 5; tolField.Layout.Column = 2;

    lbl = uilabel(g,'Text','Initial y (RK4):'); lbl.Layout.Row = 6; lbl.Layout.Column = 1;
    y0Field = uieditfield(g,'numeric','Value',1); y0Field.Layout.Row = 6; y0Field.Layout.Column = 2;
    lbl = uilabel(g,'Text','Final x (RK4):'); lbl.Layout.Row = 7; lbl.Layout.Column = 1;
    xEndField = uieditfield(g,'numeric','Value',0.2); xEndField.Layout.Row = 7; xEndField.Layout.Column = 2;
    runButton = uibutton(g,'push','Text','Calculate','FontWeight','bold');
    runButton.Layout.Row = 8; runButton.Layout.Column = [1 2];

    % Explanation and result panel
    infoPanel = uipanel(main,'Title','Assignment problem and result');
    infoPanel.Layout.Row = 1; infoPanel.Layout.Column = 2;
    info = uitextarea(infoPanel,'Editable','off','Position',[10 10 700 100]);
    info.Value = {'Newton-Raphson: f(x) = x^3 - x - 2; derivative = 3x^2 - 1.', ...
        'Secant: f(x) = x^3 - x - 2.', ...
        'RK4: dy/dx = x + y; enter x0, y0, step size h and final x in the fields below.'};

    % Results table
    tablePanel = uipanel(main,'Title','Iteration results');
    tablePanel.Layout.Row = 2; tablePanel.Layout.Column = 1;
    resultsTable = uitable(tablePanel,'Position',[8 8 310 455]);
    resultsTable.Data = cell(0,4);
    resultsTable.ColumnName = {'Iteration','x','Value / y','Error / k1'};

    % Plot
    plotPanel = uipanel(main,'Title','Graph');
    plotPanel.Layout.Row = 2; plotPanel.Layout.Column = 2;
    ax = uiaxes(plotPanel,'Position',[45 45 650 410]);
    grid(ax,'on'); xlabel(ax,'x'); ylabel(ax,'f(x) or y');

    methodDrop.ValueChangedFcn = @updateDescription;
    runButton.ButtonPushedFcn = @calculate;
    updateDescription();

    function updateDescription(~,~)
        switch methodDrop.Value
            case 'Newton-Raphson'
                tolField.Value = 0.0001;
                info.Value = {'Solve f(x) = x^3 - x - 2 using Newton-Raphson.', ...
                    'Derivative: f''(x) = 3x^2 - 1. Enter the starting estimate x0.', ...
                    'Tolerance is used as the stopping error; maximum iterations = 100.'};
            case 'Secant'
                tolField.Value = 0.0001;
                info.Value = {'Solve f(x) = x^3 - x - 2 using the Secant method.', ...
                    'Enter two starting estimates x0 and x1.', ...
                    'Tolerance is used as the stopping error; maximum iterations = 100.'};
            case 'Runge-Kutta RK4'
                tolField.Value = 0.1;
                info.Value = {'Solve dy/dx = x + y using fourth-order Runge-Kutta.', ...
                    'Enter x0, y0, step size h and final x.', ...
                    'The tolerance field is used as the step size h for RK4.'};
        end
    end

    function calculate(~,~)
        x0 = x0Field.Value;
        x1 = x1Field.Value;
        tol = tolField.Value;
        maxIter = 100;
        cla(ax); grid(ax,'on');
        try
            switch methodDrop.Value
                case 'Newton-Raphson'
                    [data,root,converged] = newtonMethod(x0,tol,maxIter,loopDrop.Value);
                    resultsTable.Data = data;
                    title(ax,'Newton-Raphson: f(x) = x^3 - x - 2');
                    xx = linspace(min([0 root])-1,max([2 root])+1,300);
                    plot(ax,xx,xx.^3-xx-2,'LineWidth',1.5); hold(ax,'on');
                    yline(ax,0,'--'); plot(ax,root,0,'ro','MarkerFaceColor','r'); hold(ax,'off');
                    xlabel(ax,'x'); ylabel(ax,'f(x)');
                    if converged, status='Converged'; else, status='Maximum iterations reached'; end
                    uialert(fig,sprintf('%s\nApproximate root = %.8f',status,root),'Calculation complete');

                case 'Secant'
                    [data,root,converged] = secantMethod(x0,x1,tol,maxIter,loopDrop.Value);
                    resultsTable.Data = data;
                    title(ax,'Secant: f(x) = x^3 - x - 2');
                    xx = linspace(min([0 root])-1,max([2 root])+1,300);
                    plot(ax,xx,xx.^3-xx-2,'LineWidth',1.5); hold(ax,'on');
                    yline(ax,0,'--'); plot(ax,root,0,'ro','MarkerFaceColor','r'); hold(ax,'off');
                    xlabel(ax,'x'); ylabel(ax,'f(x)');
                    if converged, status='Converged'; else, status='Maximum iterations reached'; end
                    uialert(fig,sprintf('%s\nApproximate root = %.8f',status,root),'Calculation complete');

                case 'Runge-Kutta RK4'
                    h = tol;
                    if h <= 0 || xEndField.Value <= x0
                        error('For RK4, h must be positive and final x must be greater than initial x.');
                    end
                    [data,xVals,yVals] = rk4Method(x0,y0Field.Value,h,xEndField.Value,loopDrop.Value);
                    resultsTable.Data = data;
                    plot(ax,xVals,yVals,'o-','LineWidth',1.5);
                    title(ax,'RK4 solution of dy/dx = x + y');
                    xlabel(ax,'x'); ylabel(ax,'y');
                    uialert(fig,sprintf('RK4 final approximation:\ny(%.6g) = %.8f',xVals(end),yVals(end)),'Calculation complete');
            end
        catch ME
            uialert(fig,ME.message,'Input or calculation error','Icon','error');
        end
    end
end

function [data,x,converged] = newtonMethod(x,tol,maxIter,loopType)
    f = @(z) z.^3-z-2;
    df = @(z) 3*z.^2-1;
    data = cell(0,4); converged = false; i = 0;
    if strcmp(loopType,'FOR loop')
        for k = 1:maxIter
            if abs(df(x)) < eps, error('Derivative is zero or too small.'); end
            xn = x-f(x)/df(x); err = abs(xn-x); i=k;
            data(end+1,:) = {i,xn,f(xn),err}; %#ok<AGROW>
            x=xn;
            if err < tol, converged=true; break; end
        end
    else
        while i < maxIter
            if abs(df(x)) < eps, error('Derivative is zero or too small.'); end
            xn = x-f(x)/df(x); err = abs(xn-x); i=i+1;
            data(end+1,:) = {i,xn,f(xn),err}; %#ok<AGROW>
            x=xn;
            if err < tol, converged=true; break; end
        end
    end
end

function [data,x2,converged] = secantMethod(x0,x1,tol,maxIter,loopType)
    f = @(z) z.^3-z-2;
    data = cell(0,4); converged=false; i=0;
    if strcmp(loopType,'FOR loop')
        for k=1:maxIter
            den=f(x1)-f(x0);
            if abs(den)<eps, error('Secant denominator is zero or too small.'); end
            x2=x1-f(x1)*(x1-x0)/den; err=abs(x2-x1); i=k;
            data(end+1,:)={i,x2,f(x2),err}; %#ok<AGROW>
            x0=x1; x1=x2;
            if err<tol, converged=true; break; end
        end
    else
        while i<maxIter
            den=f(x1)-f(x0);
            if abs(den)<eps, error('Secant denominator is zero or too small.'); end
            x2=x1-f(x1)*(x1-x0)/den; err=abs(x2-x1); i=i+1;
            data(end+1,:)={i,x2,f(x2),err}; %#ok<AGROW>
            x0=x1; x1=x2;
            if err<tol, converged=true; break; end
        end
    end
end

function [data,xVals,yVals] = rk4Method(x,y,h,xEnd,loopType)
    data=cell(0,4); xVals=x; yVals=y; i=0;
    if abs((xEnd-x)/h-round((xEnd-x)/h))>1e-8
        error('(final x - initial x) must be an exact multiple of step size h.');
    end
    nSteps=round((xEnd-x)/h);
    if strcmp(loopType,'FOR loop')
        for k=1:nSteps
            [y,k1,k2,k3,k4]=oneRK4Step(x,y,h); i=k; x=x+h;
            data(end+1,:)={i,x,y,k1}; %#ok<AGROW>
            xVals(end+1)=x; yVals(end+1)=y; %#ok<AGROW>
        end
    else
        while x < xEnd-1e-12
            [y,k1,k2,k3,k4]=oneRK4Step(x,y,h); i=i+1; x=x+h;
            data(end+1,:)={i,x,y,k1}; %#ok<AGROW>
            xVals(end+1)=x; yVals(end+1)=y; %#ok<AGROW>
        end
    end
end

function [yn,k1,k2,k3,k4] = oneRK4Step(x,y,h)
    f=@(xx,yy) xx+yy;
    k1=h*f(x,y);
    k2=h*f(x+h/2,y+k1/2);
    k3=h*f(x+h/2,y+k2/2);
    k4=h*f(x+h,y+k3);
    yn=y+(k1+2*k2+2*k3+k4)/6;
end
