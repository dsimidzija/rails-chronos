# Idea partially from: http://joshsymonds.com/blog/2012/05/16/quick-and-easy-user-preferences-in-rails/
module HasPreferences
  extend ActiveSupport::Concern

  included do
    has_many :preferences
    @@preferences = {}
  end

  module ClassMethods
    def has_preference(name, options = {})
      default_options = {
        :default => nil,
        :accessible => false,
        :validate_with => nil
      }
      options = default_options.merge(options)

      preferences = self.class_variable_get(:'@@preferences')
      preferences[name] = options[:default]
      self.class_variable_set(:'@@preferences', preferences)

      if options[:accessible]
        self.class_eval <<-eval_end
          attr_accessible :#{name}
        eval_end
      end

      unless options[:validate_with].nil?
        self.class_eval <<-eval_end
          validates :#{name}, :with => :#{options[:validate_with]}
        eval_end
      end

      self.class_eval <<-eval_end
        def #{name}=(value)
          self.preference_write('#{name}', value)
        end

        def #{name}
          p = self.preference_read('#{name}')
          return p.value if p.present?
          return @@preferences['#{name}'] if @@preferences.has_key?('#{name}')
          nil
        end
      eval_end
    end
  end

  protected

  def preference_read(name)
    pref = self.preferences.where(:name => name).first

    return pref if pref
    return self.preferences.new(:name => name, :value => @@preferences[name]) if @@preferences.has_key?(name)
    nil
  end

  def preference_write(name, value)
    pref = self.preferences.find_or_create_by_name(name)
    pref.update_attribute(:value, value)
  end
end
