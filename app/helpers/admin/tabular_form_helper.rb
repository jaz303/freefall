module Admin::TabularFormHelper
  
  #
  # Tabular Form Helper
  #
  
  def tabular_form(opts = {}, &block)
    form_opts = opts.delete(:html) || {}
    if form_opts[:class]
      form_opts[:class] = "tabular-form #{form_opts[:class]}"
    else
      form_opts[:class] = "tabular-form"
    end
    concat(form_tag(opts.delete(:url) || {}, form_opts), block.binding)
    concat("\n<table cellspacing='0' class='outer'>\n", block.binding)
    tabular_fields(opts, &block)
    concat("</table>\n</form>\n", block.binding)
  end
  
  def tabular_fields(opts = {}, &block)
    yield TabularFormBuilder.new(self, opts)
  end

  class TabularFormBuilder
    
    BUTTON_PREFIX = "<tr class='buttons'><td>&nbsp;</td><td colspan='2'>"
    BUTTON_SUFFIX = "</td></tr>"
    
    def initialize(template, options)
      @template, @options, @rows, @desc_span = template, options, 0, 1
      if options[:for].is_a?(Array)
        @for_name, @for_object = options[:for].first, options[:for].last
      elsif options[:for]
        @for_name = options[:for].to_sym
        @for_object = @template.instance_variable_get("@#{@for_name}")
      end
    end
    
    def note(text)
      "<div class='note'>#{text}</div>"
    end
    
    def heading(text)
      "<tr class='heading'><th colspan='3'>#{text}</th></tr>"
    end
    
    def buttons(opts = {}, &block)
      if block_given?
        buffer = eval("_erbout", block.binding)
        buffer << BUTTON_PREFIX
        ButtonBar.new(opts, buffer).build { |b| yield b }
        buffer << BUTTON_SUFFIX
      else
        "#{BUTTON_PREFIX}#{ButtonBar.buttons(opts)}#{BUTTON_SUFFIX}"
      end
    end
    
    def row(*args, &block)
      
      options = args.last.is_a?(Hash) ? args.pop : {}
      
      @rows += 1
      
      row_class = "item#{@rows == 1 ? ' first' : ''}"
      row_class << " #{options[:row_class]}" if options[:row_class]
      row_style = options[:row_style] ? "style='#{options[:row_style]}'" : ''
      
      prefix, suffix, span = "<tr class='#{row_class}'#{row_style}>", "", 2
      span += 1 if options[:span]
      
      if options[:label]
        if options[:required]
          label_class = ' class="required"'
          options[:label] = "* #{options[:label]}"
        else
          label_class = ''
        end
        prefix << "<td class='label'><label#{label_class}>#{options[:label]}</label></td>"
        span -= 1
      end
        
      rendered_note = options[:note] ? note(options[:note]) : ""
      
      if @desc_span > 1
        @desc_span -= 1
        span -= 1 if options[:span]
      else
        
        @desc_span = options[:desc_span] || 1
        
        error_message = options[:error]
        if @for_object && options[:for]
          error_message = [options[:for]].flatten.inject([]) { |memo, field|
            returning(memo) do |m|
              e = @for_object.errors.on(field)
              m.concat([e].flatten) if e
            end
          }.join(', ')
        end
        
        if !error_message.blank?
          suffix << "<td rowspan='#{@desc_span}' class='error'>#{error_message}</td>"
        elsif options[:desc]
          suffix << "<td rowspan='#{@desc_span}' class='description'>#{options[:desc]}</td>"
        else
          suffix << "<td></td>"
        end
        
      end
      
      suffix << "</tr>"
      prefix << "<td colspan='#{span}'>"
      
      if block_given?
        buffer = eval("_erbout", block)
        buffer << prefix
        yield self
        buffer << rendered_note
        buffer << suffix
      else
        "#{prefix}#{args.join('')}#{rendered_note}</td>#{suffix}"
      end
      
    end

    # Delegate to the template, after injecting the name of the object
    # This means we get all of the standard field helpers, plus any extras
    # (TinyMCE?) - for free.
    def method_missing(method, *args, &block)
      raise "Can't delegate to field helper - no associated model" unless @for_name
      @template.send(method, *(args.unshift(@for_name)), &block)
    end

  end
  
  #
  # Button Bar Helper
  #
  
  def buttons(opts = {}, &block)
    ButtonBar.buttons(opts, &block)
  end
  
  class ButtonBar
    
    def initialize(opts, buffer)
      @buffer = buffer
    end
    
    def build
      @buffer << "<div class='buttons'>"
      yield self
      @buffer << "</div>"
    end
    
    def submit(text = 'Save', name = nil)
      "<input type='submit' class='submit' name='#{name}' value='#{text}' /> "
    end
    
    def cancel(text = 'Cancel', url = :back)
      if url == :back
        "<input type='button' class='cancel' value='#{text}' onclick='history.go(-1); return false;' /> "
      else
        "<input type='button' class='cancel' value='#{text}' onclick='window.location=\"#{url}\"; return false;' /> "
      end
    end
    
    def reset(text = 'Reset')
      "<input type='reset' value='#{text}' /> "
    end
    
    def nav(text, url)
      "<input type='button' value='#{text}' onclick='window.location=\"#{url}\"' />"
    end
    
    def self.buttons(opts = {}, &block)
      if block_given?
        ButtonBar.new(opts, eval("_erbout", block.binding)).build { |b| yield b }
      else
        buffer = ""
        ButtonBar.new({}, buffer).build do |b|    
          buffer << b.submit(opts[:save] || "Save") unless opts[:save] === false
          buffer << b.cancel(opts[:cancel] || "Cancel", opts[:cancel_url] || :back) unless opts[:cancel] === false
          buffer << b.reset(opts[:reset] === true ? 'Reset' : opts[:reset]) if opts[:reset]
        end
        buffer
      end
    end
    
  end
  
end
