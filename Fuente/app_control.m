classdef app_control < handle
    %CONTROLLER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        view_obj;
        
        camera_handler_obj;
        camera_timer;
        
        last_webcam_im;
        loaded_image;
        empty_image;
        
        background_image;
        
        apply_improcess;
        selected_improcess;
    end
    
    methods (Access = private)
        
        function show_camera(obj)
            image = obj.camera_handler_obj.get_snapshot();
            if ~isempty(image)
                if obj.apply_improcess
                    obj.view_obj.display_image(obj.selected_improcess.process(image));
                else
                    obj.view_obj.display_image(image);
                end
                
                obj.last_webcam_im = image;
            end
        end
        
        function show_image(obj)
            image = obj.loaded_image;
            if isempty(image); image = obj.empty_image; end
            
            if obj.apply_improcess
                progress_bar = uiprogressdlg(obj.view_obj.UIFigure, 'Title', 'Applying image process', 'Indeterminate', 'on');
                
                obj.view_obj.display_image(obj.selected_improcess.process(image));
                
                close(progress_bar);
            else
                obj.view_obj.display_image(image);
            end
        end
        
        function turnOn_cam(obj)
            obj.camera_handler_obj.open_camera()
            
            obj.camera_timer = timer('StartDelay', 1, 'Period', 1e-3, 'TasksToExecute', Inf, 'ExecutionMode', 'fixedRate');
            obj.camera_timer.TimerFcn = @(~, ~) show_camera(obj);
            
            start(obj.camera_timer);
        end
        
        function turnOff_cam(obj)
            % turn off image
            obj.view_obj.display_image(obj.empty_image);

            % turn off timer
            if isa(obj.camera_timer, 'timer')
                stop(obj.camera_timer);
                delete(obj.camera_timer);

                obj.camera_timer = 0;
            end

            % turn off camera
            obj.camera_handler_obj.close_camera()
        end
        
        function turnOff_apply(obj)
            obj.view_obj.ApplyprocessingSwitch.Value = "Off";
            obj.apply_improcess = 0;
        end
        
        function [tag] = convertHumanDetectionTag(obj, type)
            
            switch type
                case obj.view_obj.DetectiontypeDropDown.Items(1)
                    tag = 'FrontalFaceLBP';
                    % face
                case obj.view_obj.DetectiontypeDropDown.Items(2)
                    tag = 'UpperBody';
                    % upperbody
                otherwise
                    tag = 'FrontalFaceLBP';
                    % default : upperbody
            end
        end
        
    end
    
    methods
        function obj = app_control()
            addpath(genpath('./improcess/'));
            
            obj.view_obj = app_view(obj);
            obj.camera_handler_obj = camera_handler("winvideo");
            obj.empty_image = zeros(obj.view_obj.UIAxes.Position(3), obj.view_obj.UIAxes.Position(4), 3);
            obj.loaded_image = [];
            obj.background_image = [];
            
            
            obj.selected_improcess = bw_improcess();
            obj.apply_improcess = strcmp(obj.view_obj.ApplyprocessingSwitch.Value, "On");
        end
        
        %%%%%%%%%%
        % webcam %
        %%%%%%%%%%
        
        function change_camera_status(obj, event)
            % camera status switch listener
            value = obj.view_obj.CameraStatusSwitch.Value;
            progress_bar = uiprogressdlg(obj.view_obj.UIFigure,'Title',append('Turning ', value, ' Camera'),'Indeterminate','on');
            drawnow
            
            if strcmp(value, "On")
                obj.turnOn_cam();
            elseif strcmp(value, "Off")
                obj.turnOff_cam();
                
                % turn off apply
                obj.turnOff_apply();
            end
            
            close(progress_bar);
        end
        
        function change_image_source(obj, event)
            value = obj.view_obj.ImagesourceDropDown.Value;
            
            switch value
                case 'Image'
                    obj.view_obj.disable_webcam();
                    if strcmp(obj.view_obj.CameraStatusSwitch.Value, "On")
                        obj.view_obj.CameraStatusSwitch.Value = "Off";
                        obj.turnOff_cam();
                    end
                    obj.view_obj.GetimagefileButton.Visible = true;
                    
                    obj.show_image();
                case 'Webcam'
                    obj.view_obj.enable_webcam();
                    obj.view_obj.GetimagefileButton.Visible = false;
                    obj.view_obj.display_image(obj.empty_image);
                otherwise
                    % error
                    uialert(obj.view_obj.UIFigure, 'Invalid input source', 'Invalid Input Source');
            end
            
            % turn off apply
            obj.turnOff_apply();
        end
        
        function close_request(obj, event)
            value = obj.view_obj.CameraStatusSwitch.Value;
            
            if strcmp(value, "On"); obj.turnOff_cam(); end
            
            delete(obj.view_obj)
        end
        
        %%%%%%%%%
        % image %
        %%%%%%%%%
        
        function get_image_file(obj, event)
            [filename, pathname] = uigetfile({'*.png';'*.jpg';'*.jpeg';'bmp'},'Select image');
            figure(obj.view_obj.UIFigure); % recover focus https://es.mathworks.com/matlabcentral/answers/296305-appdesigner-window-ends-up-in-background-after-uigetfile
            
            if isequal(filename,0)
                uialert(obj.view_obj.UIFigure, 'File not found', 'Invalid File');
                return;
            end
            inputimage=strcat(pathname, filename);
            obj.loaded_image = imread(inputimage);
            
            obj.show_image();
        end
        
        function get_bg_file(obj, event)
            [filename, pathname] = uigetfile({'*.png';'*.jpg';'*.jpeg';'bmp'},'Select image');
            figure(obj.view_obj.UIFigure); % recover focus https://es.mathworks.com/matlabcentral/answers/296305-appdesigner-window-ends-up-in-background-after-uigetfile
            
            if isequal(filename,0)
                uialert(obj.view_obj.UIFigure, 'File not found', 'Invalid File');
                return;
            end
            inputimage=strcat(pathname, filename);
            obj.background_image = imread(inputimage);
            
            obj.view_obj.display_bg(obj.background_image);
            
            if strcmp(obj.view_obj.TabGroup.SelectedTab.Title, "Chroma") || ...
               strcmp(obj.view_obj.TabGroup.SelectedTab.Title, "Human detection")
                obj.selected_improcess.background = obj.background_image;
            end
            
            if strcmp(obj.view_obj.ImagesourceDropDown.Value, "Image")
                obj.show_image();
            end
        end
        
        %%%%%%%%%%%%%%
        % processing %
        %%%%%%%%%%%%%%
        
        function apply_processing(obj, event)
            apply_status = obj.view_obj.ApplyprocessingSwitch.Value;
            
            exist_fg_img = ~isempty(obj.loaded_image);
            cam_is_on = strcmp(obj.view_obj.CameraStatusSwitch.Value, "On");
            exist_bg_im = ~isempty(obj.background_image);
            
            if strcmp(apply_status, "On") && ( ( ~exist_fg_img && ~cam_is_on ) || ~exist_bg_im )
                obj.view_obj.ApplyprocessingSwitch.Value = "Off";
                uialert(obj.view_obj.UIFigure, "Select foreground and background image", 'Error apply processing');
                return
                % err
            end
            
            obj.apply_improcess = strcmp(apply_status, "On");
            
            if strcmp(obj.view_obj.ImagesourceDropDown.Value, 'Image'); obj.show_image(); end
        end
        
        %%%%%%%%%%%%%%%%%%%%
        % method selection %
        %%%%%%%%%%%%%%%%%%%%
        
        function select_method(obj, event)
            value = obj.view_obj.TabGroup.SelectedTab.Title;
            
            switch value
                case "Gray image"
                    obj.selected_improcess = bw_improcess();
                    % 
                case "Chroma"
                    color = obj.view_obj.SelectedcolorLamp.Color;
                    t1 = obj.view_obj.Threhold1Slider.Value;
                    t2 = obj.view_obj.Threhold2Slider.Value;
                    ga = obj.view_obj.GaussianradiusSpinner.Value;
                    bg = obj.background_image;
                    obj.selected_improcess = chroma_improcess(color, t1, t2, ga, bg);
                    %
                case "Human detection"
                    detection_type = obj.convertHumanDetectionTag(obj.view_obj.DetectiontypeDropDown.Value);
                    background_percentage = obj.view_obj.BackgroundpercentageSlider.Value;
                    gaussian_radius = obj.view_obj.GaussianradiusSpinner_humandet.Value;
                    subdivision_rate = obj.view_obj.SubdivisionrateSlider.Value;
                    show_detected =  obj.view_obj.ShowdetectionButton.Value;
                    obj.selected_improcess = humandetect_improcess(detection_type, ...
                                                                     background_percentage, ...
                                                                     gaussian_radius, ...
                                                                     subdivision_rate, ...
                                                                     obj.background_image, ...
                                                                     show_detected);
                    
                    %
                otherwise
                    uialert(obj.view_obj.UIFigure, 'Method not found', 'Invalid Method');
            end
            
            if strcmp(obj.view_obj.ImagesourceDropDown.Value, "Image"); obj.show_image(); end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % chroma method parameters listeners %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function pick_color(obj, event)
            cam_ison = strcmp(obj.view_obj.CameraStatusSwitch.Value, "On");
            img_loaded = ~isempty(obj.loaded_image);
            
            if ~img_loaded && ~cam_ison
                uialert(obj.view_obj.UIFigure, 'Image not found', 'Invalid Image');
                return % error
            end
            
            image = obj.loaded_image;
            if cam_ison
                image = obj.last_webcam_im;
            end
           
            imshow(image);
            try
                [y,x] = ginput(1);
            catch
                uialert(obj.view_obj.UIFigure, 'Unable to pick color', 'Error');
                return % error
            end
            x = round(x);
            y = round(y);
            
            r = image(x, y, 1);
            g = image(x, y, 2);
            b = image(x, y, 3);
            
            
            obj.view_obj.SelectedcolorLamp.Color = [r, g, b];
            
            close;
            
            obj.selected_improcess.pick_color = [r, g, b];
            % update image
            if strcmp(obj.view_obj.ImagesourceDropDown.Value, "Image"); obj.show_image(); end
        end
        
        function update_chroma_parameters(obj, event)
            t1 = obj.view_obj.Threhold1Slider.Value;
            t2 = obj.view_obj.Threhold2Slider.Value;
            ga = obj.view_obj.GaussianradiusSpinner.Value;
            
            obj.selected_improcess.t1 = t1;
            obj.selected_improcess.t2 = t2;
            obj.selected_improcess.gaussian_radius = ga;
            
            if strcmp(obj.view_obj.ImagesourceDropDown.Value, "Image"); obj.show_image(); end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % human detection method parameters listeners %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function update_human_detection_parameters(obj, event)
            detection_type = obj.convertHumanDetectionTag(obj.view_obj.DetectiontypeDropDown.Value);
            background_percentage = obj.view_obj.BackgroundpercentageSlider.Value;
            gaussian_radius = obj.view_obj.GaussianradiusSpinner_humandet.Value;
            subdivision_rate = obj.view_obj.SubdivisionrateSlider.Value;
            show_detected =  obj.view_obj.ShowdetectionButton.Value;
            
            obj.selected_improcess.detection_type = detection_type;
            obj.selected_improcess.background_percentage = background_percentage;
            obj.selected_improcess.gaussian_radius = gaussian_radius;
            obj.selected_improcess.subdivision_rate = subdivision_rate;
            
            obj.selected_improcess.show_detected = show_detected;
            
            if strcmp(obj.view_obj.ImagesourceDropDown.Value, "Image"); obj.show_image(); end
            
        end
        
    end
end

