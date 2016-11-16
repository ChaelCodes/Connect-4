class Board < ActiveRecord::Base
    def players
        return [1, 2]
    end
end
