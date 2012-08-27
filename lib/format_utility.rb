
module FormatUtility
  def date_input_format
    I18n.t :input, :scope => [:date, :formats]
  end

  def time_input_format
    I18n.t :input, :scope => [:time, :formats]
  end

  def date_input_format_js
    I18n.t :input, :scope => [:date_js, :formats]
  end

  def time_input_format_js
    I18n.t :input, :scope => [:time_js, :formats]
  end
end
