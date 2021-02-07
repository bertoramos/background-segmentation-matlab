classdef humandetect_improcess < improcess
    %HUMANDETECT_IMPROCESS Applies human detection image segmentation
    %   Applies human detection and background segmentation
    
    properties
        background_percentage
        detection_type
        gaussian_radius
        subdivision_rate
        show_detected
    end
    
    methods
        function obj = humandetect_improcess(detection_type, background_percentage, gaussian_radius, subdivision_rate, background_image, show_detected)
            %HUMANDETECT_IMPROCESS Construct an instance of this class
            %   detection_type: [string] "FrontalFaceLBP", "UpperBody"
            %   background_percentage: [double]  Background rate
            %   gaussian_radius: [double]   gaussian filter radius (>0)
            %   subdivision_rate: [double]  subdivision rate for lazysnapping
            %   background_image: [uint8 matrix] background image
            %   show_detection: [bool]
            
            obj.background_percentage = background_percentage;
            obj.detection_type = detection_type;
            obj.gaussian_radius = gaussian_radius;
            obj.subdivision_rate = uint8(subdivision_rate);
            obj.background = background_image;
            obj.show_detected = show_detected;
        end
        
        function imres = process(obj, im)
            imres = human_segment(im, obj.background, ...
                                    obj.detection_type, ...
                                    obj.background_percentage, ...
                                    obj.gaussian_radius, ...
                                    obj.subdivision_rate, ...
                                    obj.show_detected);
            
        end
    end
end

