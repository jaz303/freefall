module Freefall
  module Attribution
    
    def self.copyright
      "2006-2010 " + authors.map { |a| a[:name] }.join(', ')
    end
    
    def self.authors
      [ { :name       => "Jason Frame",
          :email      => "jason@onehackoranother.com",
          :url        => "http://onehackoranother.com"
        },
        { :name       => "Lewis Mackenzie"
        }
      ]
    end
    
  end
end