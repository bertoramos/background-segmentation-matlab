classdef chroma_improcess < improcess
    %CHROMA_IMPROCESS Applies chroma keying algorithm
    
    properties
        pick_color
        t1
        t2
        gaussian_radius
    end
    
    methods
        function obj = chroma_improcess(pick_color, t1, t2, gaussian_radius, background)
            %CHROMA_IMPROCESS Construct an instance of this class
            %   pick_color : [uint8 vector] key color
            %   t1 : [double] lower threshold
            %   t2 : [double] higher threshold
            %   gaussian_radius : [double] gaussian filter radius (> 0)
            %   background : [uint8 matrix] background image
            obj.pick_color = pick_color;
            obj.t1 = t1;
            obj.t2 = t2;
            obj.gaussian_radius = gaussian_radius;
            obj.background = background;
        end
        
        function imres = process(obj, im)
            imres = chroma(im, obj.background, obj.pick_color, obj.t1, obj.t2, obj.gaussian_radius);
        end
    end
end

