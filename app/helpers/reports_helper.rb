module ReportsHelper
  def css_class_for_percent(percent, date)
    return '' if [0,6].include?(date.wday)

    return 'label label-important' if percent < 0.95
    return 'label label-warning' if (0.95..0.99).include?(percent)
    return 'label label-success' if percent >= 1.1
    'label label-info'
  end
end
