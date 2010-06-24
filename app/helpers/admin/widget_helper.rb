module Admin
  module WidgetHelper
    
    #
    # General widget bits
    
    def widget_config(hash)
      content_tag(:script, "return #{hash.to_json};", :type => 'text/javascript-widget-config')
    end
    
    #
    # Tab Bar
    
    def tab_bar
      builder = TabBarBuilder.new(self)
      yield builder if block_given?
      concat(builder.to_s)
    end
    
    class TabBarBuilder
      def initialize(template)
        @t, @tabs = template, []
      end
      
      def tab(title, &block)
        @tabs << [title, @t.capture(&block)]
      end
      
      def to_s
        @t.content_tag(:div,
          @t.content_tag(:ul,
            @tabs.map { |t| @t.content_tag(:li, @t.content_tag(:a, t.first, :href => '#')) },
            :class => 'tab-bar'
          ) + @tabs.map { |t|
            @t.content_tag(:div, t.last, :class => 'panel')
          }.join("\n").html_safe,
          :class => 'widget widget-TabPane'
        ) 
      end
    end
  
  end
end