classdef bw_improcess < improcess
    %DEMO_IMPROCESS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public)
        option
    end
    
    methods
        function obj = bw_improcess()
            %BW_IMPROCESS Construct an instance of this class
            %   Detailed explanation goes here
        end
        
        function imres = process(obj, im)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            imres = im2gray(im);
        end
    end
end

