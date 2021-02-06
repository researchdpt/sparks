module Helpers        
    class << self   
        attr_accessor :api_dict
    end
    
    class APIDict
        def initialize
            @@apis = {}
        end

        def add api, obj
            @@apis[api] = obj
        end

        def get api
            if @@apis.key? api
                @@apis[api]
            else
                false
            end
        end
    end

    self.api_dict = APIDict.new
end
