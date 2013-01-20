require 'test_helper'

class TimeEntryTest < ActiveSupport::TestCase
  fixtures :time_entries

  test "lunch break detection - no break" do
    del = users(:delboy)
    start_entry = time_entries(:lunch_detect_one)
    entries = TimeEntry.where(
        :user_id => del.id,
        :entry_date => start_entry.entry_date)
      .order(:start_time => :asc)

    expected = { start_entry.entry_date.day.to_s.to_sym => false }
    result = TimeEntry.detect_lunch_breaks_by_day(start_entry.entry_date, start_entry.entry_date, entries, 30)

    assert_equal expected, result
  end

  test "lunch break detection - yes break" do
    del = users(:delboy)
    start_entry = time_entries(:lunch_detect_three)
    entries = TimeEntry.where(
        :user_id => del.id,
        :entry_date => start_entry.entry_date)
      .order(:start_time => :asc)

    expected = { start_entry.entry_date.day.to_s.to_sym => true }
    result = TimeEntry.detect_lunch_breaks_by_day(start_entry.entry_date, start_entry.entry_date, entries, 30)

    assert_equal expected, result
  end
end
