module ReportsHelper
  def css_class_for_percent(percent, date)
    return '' if [0,6].include?(date.wday)

    return 'time_insufficient' if percent < 0.95
    return 'time_warning' if (0.95..0.99).include?(percent)
    return 'time_success' if percent >= 1.1
    'time_ok'
  end

  def css_class_for_empty_cell(percent)
    'empty' if percent == 0
  end
 
  def css_class_for_non_workday(date)
    classes = []
    country = @current_user.country.to_sym
    classes << 'weekend' if weekend?(date)

    if Holidays.available.include?(country)
      classes << 'holiday' if date.holiday?(country)
    end

    classes.join(' ')
  end

  def weekend?(day)
    day = day.wday if day.respond_to?(:wday)
    return true if [0,6].include?(day)

    false
  end

  def number_for_report(number)
    number_to_human number, :separator => ',', :precision => 2, :significant => false
  end

  def user_holiday?(day)
    country = @current_user.country

    if Holidays.available.include?(country)
      return date.holiday?(country)
    end

    false
  end
end
