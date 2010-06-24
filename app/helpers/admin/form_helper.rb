module Admin
  module FormHelper
    
    #
    # Rich Text Editor (TinyMCE)
    
    def rich_text_field(instance, method, *options)
      object = instance_variable_get("@#{instance.to_s}")
      method = method.to_sym if method
      if object && method && object.respond_to?(method)
        content = object.send(method)
      else
        content = ''
      end
      rich_text_field_tag("#{instance}[#{method}]", content, *options)
    end

    # Creates a TinyMCE field with explicit name and content
    def rich_text_field_tag(name, value = '', *args)
      options = args.extract_options!
      classes = args.map { |o| "tinymce-options-#{o}" }
      id = options[:id] || (name.to_s + "___tinymce")
      text_area_tag(name, value, :id => id, :class => "tinymce #{classes.join(' ')}")
    end
    
    #
    # Popup Calendar
    
    ISO8601 = "%Y-%m-%dT%H:%M:%S"
    
    def calendar_date_tag(name, value = nil, options = {})
      
      if value
        value = value.to_time if value.respond_to?(:to_time)
      else
        value = Time.now
      end
      
      if options[:time]
        base_class = 'datetime-picker'
      else
        base_class = 'date-picker'
        value = value.midnight
      end
      
      html  = "<span class='#{base_class}'>"
      html << "<input type='text' value='' />"
      html << "<input type='hidden' name='#{name}' value='#{value.strftime(ISO8601)}' />"
      html << "<a href='#'>#{icon(:calendar)}</a>"
      html << "</span>"
      
      html.html_safe
    
    end
    
    def calendar_date_field(instance, method, options = {})
      object = instance_variable_get("@#{instance.to_s}")
      method = method.to_sym if method
      if object && method && object.respond_to?(method)
        value = object.send(method)
      else
        value = nil
      end
      calendar_date_tag("#{instance}[#{method}]", value, options)
    end
    
    def calendar_datetime_tag(name, value = nil, options = {})
      calendar_date_tag(name, value, {:time => true}.update(options))
    end
    
    def calendar_datetime_field(instance, method, options = {})
      calendar_date_field(instance, method, {:time => true}.update(options))
    end
    
  end
end