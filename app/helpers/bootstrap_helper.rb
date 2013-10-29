module BootstrapHelper
  def icon(*names)
    content_tag(:i, nil, :class => icon_classes(names[1..-1])) + " #{names[0]}"
  end

  private
  def icon_classes(*names)
    final = ""
    names[0].each do |n|
      final = final + "icon-" + n.to_s.gsub("_", "-") + " "
    end
    return final
  end
end
