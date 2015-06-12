%% Copyright 2014 MERCIER David
function gui_handle = demo
%% Function to run the Matlab GUI for the analysis of the pop-in statistics
% through Weibull or Gauss distributions
gui = struct();
gui.config = struct();

%% Paths Management
%% Paths Management
try
    gui.config.POPINroot = get_popin_root; % ensure that environment is set
catch
    [startdir, dummy1, dummy2] = fileparts(mfilename('fullpath'));
    cd(startdir);
    commandwindow;
    path_management;
end

%% Set Toolbox version and help paths
gui.config.name_toolbox = 'PopIn';
gui.config.version_toolbox = '2.3';
gui.config.url_help = 'http://popin.readthedocs.org/en/latest/';
gui.config.pdf_help = 'https://media.readthedocs.org/pdf/popin/latest/popin.pdf';

%% Main Window Coordinates Configuration
scrsize = get(0, 'ScreenSize'); % Get screen size
WX = 0.05 * scrsize(3);           % X Position (bottom)
WY = 0.10 * scrsize(4);           % Y Position (left)
WW = 0.90 * scrsize(3);           % Width
WH = 0.80 * scrsize(4);           % Height

%% Main Window Configuration
gui.handles.MainWindows = figure('Name', ...
    strcat(gui.config.name_toolbox, '_Version_', gui.config.version_toolbox),...
    'NumberTitle', 'off',...
    'PaperUnits', get(0, 'defaultfigurePaperUnits'),...
    'Color', [0.9 0.9 0.9],...
    'Colormap', get(0,'defaultfigureColormap'),...
    'toolBar', 'figure',...
    'InvertHardcopy', get(0, 'defaultfigureInvertHardcopy'),...
    'PaperPosition', [0 7 50 15],...
    'Position', [WX WY WW WH]);

%% Title of the GUI
gui.handles.title_1 = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'text',...
    'Position', [0.325 0.96 0.55 0.04],...
    'String', 'Analysis of the pop-in statistics through Weibull distribution',...
    'FontWeight', 'bold',...
    'FontSize', 12,...
    'HorizontalAlignment', 'center',...
    'ForegroundColor', 'red');

gui.handles.title_2 = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'text',...
    'Position', [0.325 0.93 0.55 0.03],...
    'String', ['Version ', gui.config.version_toolbox, ...
    ' - Copyright 2014 MERCIER David'],...
    'FontWeight', 'bold',...
    'FontSize', 10,...
    'HorizontalAlignment', 'center',...
    'ForegroundColor', 'red');

%% Date / Time
gui.handles.date = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'text',...
    'String', datestr(datenum(clock),'mmm.dd,yyyy HH:MM'),...
    'Position', [0.92 0.975 0.075 0.02]);

%% Variables definition
x_coord = 0.018;

%% Buttons to browse in files
gui.handles.opendata = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'pushbutton',...
    'Position', [x_coord 0.94 0.06 0.05],...
    'String', 'Select file',...
    'FontSize', 10,...
    'FontWeight','bold',...
    'BackgroundColor', [0.745 0.745 0.745],...
    'Callback', 'openfile');

gui.handles.opendata_str = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'edit',...
    'Position', [0.078 0.94 0.2 0.05],...
    'String', pwd,...
    'FontSize', 8,...
    'BackgroundColor', [0.9 0.9 0.9]);

gui.handles.typedata = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'text',...
    'Position', [x_coord 0.92 0.26 0.02],...
    'String', '.xls ==> 3 columns : Segments / Displacement / Load ',...
    'HorizontalAlignment', 'left');

%% Units definition
gui.settings.ListLoadUnits = {'nN';'uN';'mN'};
gui.settings.ListDispUnits = {'nm';'um';'mm'};

% Unit definition for the load
gui.handles.title_unitLoad = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'text',...
    'Position', [x_coord 0.89 0.025 0.02],...
    'String', 'Load :',...
    'HorizontalAlignment', 'left');

gui.handles.unitLoad = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'popupmenu',...
    'Position', [0.043 0.89 0.04 0.02],...
    'String', gui.settings.ListLoadUnits,...
    'Value', 3,...
    'Callback', 'get_and_plot');

% Unit definition for the displacement
gui.handles.title_unitDisp = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'text',...
    'Position', [0.093 0.89 0.055 0.02],...
    'String', 'Displacement :',...
    'HorizontalAlignment', 'left');

gui.handles.unitDisp = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'popupmenu',...
    'Position', [0.148 0.89 0.04 0.02],...
    'String', gui.settings.ListDispUnits,...
    'Value', 1,...
    'Callback', 'get_and_plot');

%% Definition of temperature of experiments
[gui.handles.title_temperature, gui.handles.value_temperature, ...
    gui.handles.unit_temperature] = ...
    set_inputs_boxes('Temperature :', '20', '�C', ...
    [x_coord 0.85 0.1 0.025], '', 0.65, gcf);

%% Definition of temperature of experiments
[gui.handles.title_loadrate, gui.handles.value_loadrate, ...
    gui.handles.unit_loadrate] = ...
    set_inputs_boxes('Load rate :', '0.05', 'mN/s', ...
    [x_coord 0.82 0.1 0.025], '', 0.65, gcf);

%% Definition of the minimum/maximum depth
[gui.handles.title_mindepth, gui.handles.value_mindepth, ...
    gui.handles.unit_mindepth] = ...
    set_inputs_boxes('Minimum depth', '', 'nm', ...
    [x_coord 0.79 0.1 0.025], '', 0.65, gcf);

[gui.handles.title_maxdepth, gui.handles.value_maxdepth, ...
    gui.handles.unit_maxdepth] = ...
    set_inputs_boxes('Maximum depth :', '', 'nm', ...
    [x_coord 0.76 0.1 0.025], '', 0.65, gcf);

%% Number of pop-in
gui.handles.title_num_popin = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'text',...
    'Position', [x_coord 0.72 0.15 0.03],...
    'String', 'Which pop-in to analyze ?',...
    'HorizontalAlignment', 'left');

gui.handles.value_num_popin = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'popup',...
    'Position', [x_coord 0.69 0.15 0.03],...
    'String', '1st pop-in|2nd pop-in',...
    'Value', 1);

%% Set the critical parameter
gui.handles.title_crit_param = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'text',...
    'Position', [x_coord 0.66 0.15 0.03],...
    'String', 'Which critical parameter to analyze ?',...
    'HorizontalAlignment', 'left');

gui.handles.value_crit_param = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'popup',...
    'Position', [x_coord 0.63 0.15 0.03],...
    'String', 'Load|Displacement',...
    'Value', 1);

%% Plot Hertzian fit
gui.handles.cb_Hertzian_plot = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'checkbox',...
    'Position', [x_coord 0.6 0.1 0.03],...
    'Value', 1,...
    'String', 'Hertzian fit',...
    'Callback', 'plot_load_disp_set');

% Young's modulus of the material in GPa
[gui.handles.title_YoungModulus, gui.handles.value_YoungModulus, ...
    gui.handles.unit_YoungModulus] = ...
    set_inputs_boxes('Young''s modulus :', '160', 'GPa', ...
    [x_coord 0.57 0.1 0.025], '', 0.65, gcf);

% Radius of the spherical indenter tip in um
[gui.handles.title_TipRadius, gui.handles.value_TipRadius, ...
    gui.handles.unit_TipRadius] = ...
    set_inputs_boxes('Tip radius :', '1', 'um', ...
    [x_coord 0.54 0.1 0.025], '', 0.65, gcf);

%% Run calculation if new parameters set
gui.handles.run_calc = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'pushbutton',...
    'Position', [x_coord 0.49 0.10 0.04],...
    'String', 'Run calculations...',...
    'FontSize', 12,...
    'BackgroundColor', [0.745 0.745 0.745],...
    'Callback', 'get_and_plot_set');

%% Parameters to plot on x and y axis
gui.handles.title_param2plotinxaxis = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'text',...
    'Position', [x_coord 0.45 0.10 0.03],...
    'String', 'Parameter to plot ==> x axis',...
    'HorizontalAlignment', 'left');

gui.handles.value_param2plotinxaxis = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'popup',...
    'Position', [x_coord 0.42 0.10 0.03],...
    'String', 'Displ.(h)|Load(L)|dh|ddh|dL|ddL',...
    'Value', 1,...
    'Callback', 'plot_load_disp_set');

gui.handles.title_param2plotinyaxis = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'text',...
    'Position', [x_coord 0.39 0.10 0.03],...
    'String', 'Parameter to plot ==> y axis',...
    'HorizontalAlignment', 'left');

gui.handles.value_param2plotinyaxis = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'popup',...
    'Position', [x_coord 0.36 0.10 0.03],...
    'String', 'Displ.(h)|Load(L)|dh|ddh|dL|ddL',...
    'Value', 2,...
    'Callback', 'plot_load_disp_set');

%% Options of the plot
gui.handles.cb_log_plot = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'checkbox',...
    'Position', [x_coord 0.32 0.03 0.03],...
    'String', 'Log',...
    'Callback', 'plot_load_disp_set');

gui.handles.cb_grid_plot = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'checkbox',...
    'Position', [0.06 0.32 0.03 0.03],...
    'String', 'Grid',...
    'Callback', 'plot_load_disp_set');

%% Get values from plot
gui.handles.cb_get_values = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'pushbutton',...
    'Position', [x_coord 0.275 0.10 0.03],...
    'String', 'Get values x and y values',...
    'Visible', 'on',...
    'Callback', 'plot_get_values');

gui.handles.title_x_values = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'text',...
    'Position', [x_coord 0.24 0.03 0.03],...
    'String', 'X value :',...
    'HorizontalAlignment', 'left',...
    'Visible', 'on');

gui.handles.value_x_values = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'edit',...
    'Position', [0.052 0.24 0.04 0.03],...
    'String', '',...
    'Visible', 'on');

gui.handles.title_y_values_prop = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'text',...
    'Position', [x_coord 0.21 0.03 0.03],...
    'String', 'Y value :',...
    'HorizontalAlignment', 'left',...
    'Visible', 'on');

gui.handles.value_y_values = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'edit',...
    'Position', [0.052 0.21 0.04 0.03],...
    'String', '',...
    'Visible', 'on');

%% Axis properties
positionVector1 = [0.25 0.06 0.325 0.75];
gui.handles.AxisPlot_1 = subplot('Position', positionVector1);

positionVector2 = [0.65 0.06 0.325 0.75];
gui.handles.AxisPlot_2 = subplot('Position', positionVector2);

%% Help
gui.handles.save = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'pushbutton',...
    'Position', [x_coord 0.15 0.1 0.05],...
    'String', 'HELP',...
    'FontSize', 12,...
    'BackgroundColor', [0.745 0.745 0.745],...
    'Callback', 'gui = guidata(gcf); web(gui.config.url_help,''-browser'')');

%% Save
gui.handles.save = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'pushbutton',...
    'Position', [x_coord 0.095 0.1 0.05],...
    'String', 'SAVE',...
    'FontSize', 12,...
    'BackgroundColor', [0.745 0.745 0.745],...
    'Callback', 'save_figures_set');

%% Quit
gui.handles.quit = uicontrol('Parent', gcf,...
    'Units', 'normalized',...
    'Style', 'pushbutton',...
    'Position', [x_coord 0.04 0.1 0.05],...
    'String', 'QUIT',...
    'FontSize', 12,...
    'BackgroundColor', [0.745 0.745 0.745],...
    'Callback', 'finish_sav');

%% Help menu
customized_menu(gcf);

%% Set flags;
gui.flag.flag_data = 0;
gui.flag.flag_cleaned_data = 0;

%% Encapsulation of data into the GUI
guidata(gcf, gui);

gui_handle = ishandle(gcf);

end