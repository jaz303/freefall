module IconHelper
  def icon_path(icon, set = nil)
    case set
    when nil
      "icons/silk/#{icon}.png"
    when :flags
      "icons/flags/#{icon}.png"
    when :mini
      "icons/mini/#{icon}.gif"
    end
  end
  
  def background_icon(icon, set = nil)
    "background-image:url(#{icon_url(icon, set)})"
  end
  
  def icon_url(icon, set = nil)
    image_path(icon_path(icon, set))
  end

  def icon(icon, options = {})
    options[:class] = options[:class].blank? ? 'icon' : "#{options[:class]} icon"
    set = options.delete(:set)
    image_tag(icon_path(icon, set), options)
  end
  
  def icon_link_to(icon, caption, options = {}, html_options = nil)      
    html_options ||= {}
    html_options[:class] ||= 'icon_link'
    link_to("#{icon(icon)} <span class='caption'>#{caption}</span>", options, html_options)
  end
end