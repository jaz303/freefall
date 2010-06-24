module Freefall
  module Admin
    module Layout

      def self.stylesheets
        %w(
          admin/main
          admin/jscalendar-1.0/calendar-win2k-1
        )
      end
      
      def self.javascripts
        %w(
          admin/jquery.min.js
          admin/jquery.rebind.js
          admin/classy.js
          admin/widgets.js
          admin/ff.js
          admin/ff-widgets.js
          admin/jscalendar-1.0/calendar_stripped.js
          admin/jscalendar-1.0/lang/calendar-en.js
          admin/jscalendar-1.0/calendar-setup.js
          admin/application.js
          tiny_mce/jquery.tinymce.js
          ff.config.admin.js
        )
      end
      
    end
  end
end
