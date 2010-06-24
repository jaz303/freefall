module Admin
  module LayoutHelper
    def admin_title
      "<h1>#{@title} <em>#{@subtitle}</em></h1>".html_safe
    end
    
    #
    # Simple HTML chunks
    
    def hr
      "<div class='hr'><hr/></div>".html_safe
    end
    
    #
    # Boolean status icons
    
    BOOLEAN_ICONS = {
      :flag => { true => :flag_green, false => :flag_red },
      :tick => { true => :tick, false => :cross },
      :thumb => { true => :thumb_up, false => :thumb_down }
    }
    
    def boolean_icon(val, set = :tick)
      icon(BOOLEAN_ICONS[set][!!val])
    end
    
    #
    # Errors
    
    def error_message(message)
      message.blank? ? '' : content_tag("div", message, :class => 'flash error')
    end
    
    #
    # Subnav
    
    def subnav_menu_item(icon, caption, url, options = {})
      options[:selected] = current_page?(url) if options[:selected].nil?
      link_to(
        content_tag(:span, caption, :class => 'caption'),
        url,
        options.merge(:style => background_icon(icon), :class => options.delete(:selected) ? 'selected' : '')
      )
    end
    
    #
    # Sidebar
    
    def sidebar_section(options = {}, &block)
      options[:title] ||= ''
      options[:title] = (icon(options[:icon]) + ' ' + options[:title]) if options[:icon]
      options[:title] = "<h2>#{options[:title]}</h2>\n" unless options[:title].blank?
      options[:id] = options[:id] ? "id='#{options[:id]}'" : ''
      
      content_for(:sidebar) do
        "<div #{options[:id]} class='section#{' ' + options[:class] if options[:class]}'>
          #{options[:title]}
          #{capture(&block)}
         </div>"
      end
    end

    def sidebar_menu(options = {}, &block)
      title = options[:title] ? "<h2>#{options[:title]}</h2>" : ''
      
      content_for(:sidebar) do
        "<div class='context'>
          #{title}
          <ul>
            #{capture(&block)}
          </ul>
         </div>"
      end
    end

    def sidebar_menu_item(icon, caption, url, selected = false, options = {})
      content_tag(
        :li,
        link_to(caption, url, options.merge(:style => background_icon(icon))),
        :class => selected ? 'selected' : ''
      )
    end
  end
end