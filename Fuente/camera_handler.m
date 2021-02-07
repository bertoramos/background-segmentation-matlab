classdef camera_handler < handle
    %CAMERA_CONTROL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        vid;
        image_source;
    end
    
    methods (Access = private)
        
    end
    
    methods
        function obj = camera_handler(image_source)
            obj.image_source=image_source;
        end
        
        function open_camera(obj)
            % turn on camera
            obj.vid = videoinput(obj.image_source,1);
            obj.vid.TriggerRepeat = 100;
            obj.vid.FrameGrabInterval = 5;

            vid_src = getselectedsource(obj.vid);
            vid_src.Tag = "motion detection setup";

            start(obj.vid);
        end
        
        function image = get_snapshot(obj)
            % si no hay frames, devuelve una imagen en negro
            if get(obj.vid,'FramesAvailable') < 1
                image = [];
            else
                image = getdata(obj.vid,1);
            end
        end
        
        function resolution = get_resolution(obj)
            resolution = obj.vid.VideoResolution;
        end
        
        function close_camera(obj)
            % turn off camera
            if isa(obj.vid, 'videoinput')
                stop(obj.vid);
                
                obj.vid = 0;
            end
        end
    end
end

