module LogChanges
  module Base
    extend ActiveSupport::Concern

    included do
      before_save  :build_changes_str, on: [:create, :update]
      after_commit :log_changes, on: [:create, :update]
    end

    # TODO: add created_by, created_at, updated_by, and updated_at
    def log_changes
      log_str = (@is_new_record ? 'New' : 'Updated') + " #{self.class.name} {id: #{id}} #{to_s}\n"
      log_str += @change_log_str if @change_log_str
      sr_log(
        self.class.name,
        "#{Time.zone.now.strftime('%-m/%-d/%Y at %-l:%M %p (%Z)')}\n#{log_str}",
        dir: Rails.root.join('log', 'record_changes').to_s
      )
    end

    def build_changes_str
      bt_assocs = self.class.reflect_on_all_associations(:belongs_to).map{|a| [a.options[:foreign_key].present? ? a.options[:foreign_key].to_s : "#{a.name}_id".to_s, {name: a.name, class: a.options[:polymorphic].present? ? nil : a.klass}]}.to_h

      @is_new_record = new_record?
      h = {}
      changes.each do |k, vals|
        bt_assoc = bt_assocs[k.to_s]
        if bt_assoc.present?
          h[bt_assoc[:name]] = []
          vals.each do |val|
            if bt_assoc[:class].nil?
              h[bt_assoc[:name]] << val
            else
              v = bt_assoc[:class].find_by_id( val )
              h[bt_assoc[:name]] << "{class: #{bt_assoc[:class].name}, id: #{val}} #{stringify_value(v)}"
            end
          end
        else
          h[k] = vals.map{|v| stringify_value(v)}
        end
      end
      @change_log_str = if new_record?
        h.map{|key_pair| "  #{key_pair[0]}: #{key_pair[1][1]}"}.join("\n")
      else
        h.map{|key_pair| "  #{key_pair[0]}:\n    FROM: #{key_pair[1][0]}\n    TO: #{key_pair[1][1]}"}.join("\n")
      end
    end

    def stringify_value val
      case
        when val.nil?
          'nil'
        when val.is_a?(Time) || val.is_a?(ActiveSupport::TimeWithZone)
          val.strftime('%-m/%-d/%Y at %-l:%M %p (%Z)')
        else
          val.to_s
      end
    end
  end
end
