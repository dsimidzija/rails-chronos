module ReportsHelper
  def css_class_for_percent(percent, date)
    return '' if [0,6].include?(date.wday)

    return 'total_time time_insufficient' if percent < 0.95
    return 'total_time time_warning' if (0.95..0.99).include?(percent)
    return 'total_time time_success' if percent >= 1.1
    'total_time time_ok'
  end

  def css_class_for_empty_cell(percent)
    'empty' if percent == 0
  end
end
