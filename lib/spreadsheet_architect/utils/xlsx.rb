module SpreadsheetArchitect
  module Utils
    module XLSX

      def self.get_type(value, type=nil)
        return type unless (type.respond_to?(:empty?) ? type.empty? : type.nil?)
        
        if value.is_a?(Numeric)
          if value.is_a?(Float) || value.is_a?(BigDecimal)
            type = :float
          else
            type = :integer
          end
        elsif value.respond_to?(:strftime)
          if value.is_a?(DateTime) || value.is_a?(Time)
            type = :time
          else
            type = :date
          end
        else
          type = :string
        end

        return type
      end

      def self.convert_styles_to_axlsx(styles={})
        styles = {} unless styles.is_a?(Hash)
        styles = self.symbolize_keys(styles)

        if styles[:fg_color].nil?
          if styles[:color].respond_to?(:sub) && !styles[:color].empty?
            styles[:fg_color] = styles.delete(:color).sub('#','')
          end
        end

        if styles[:bg_color].nil?
          if styles[:background_color].respond_to?(:sub) && !styles[:background_color].empty?
            styles[:bg_color] = styles.delete(:background_color).sub('#','')
          end
        end
        
        if styles[:alignment].nil? && styles[:align]
          if styles[:align].is_a?(Hash)
            styles[:alignment] = {
              horizontal: styles[:align][:horizontal], 
              vertical: styles[:align][:vertical], 
              wrap_text: styles[:align][:wrap_text]
            }
          else
            styles[:alignment] = {horizontal: styles.delete(:align)}
          end

          styles.delete(:align)
        end

        if styles[:b].nil?
          styles[:b] = styles.delete(:bold)
        end

        if styles[:sz].nil?
          styles[:sz] = styles.delete(:font_size)
        end

        if styles[:i].nil?
          styles[:i] = styles.delete(:italic)
        end

        if styles[:u].nil?
          styles[:u] = styles.delete(:underline)
        end
        
        styles.delete_if{|k,v| v.nil?}
      end

      def self.range_hash_to_str(hash, num_columns, num_rows, col_names=Array('A'..'ZZZ'))
        case hash[:columns]
        when Integer
          start_col = end_col = col_names[hash[:columns]]
        when Range
          start_col = col_names[hash[:columns].first]
          end_col = col_names[hash[:columns].last]
        when :all
          start_col = 'A'
          end_col = col_names[num_columns-1]
        else
          raise SpreadsheetArchitect::Exceptions::InvalidRangeStylesOptionError.new(:columns, hash)
        end

        case hash[:rows]
        when Integer
          start_row = end_row = hash[:rows]
        when Range
          start_row = hash[:rows].first
          end_row = hash[:rows].last
        when :all
          start_row = 1
          end_row = num_rows
        else
          raise SpreadsheetArchitect::Exceptions::InvalidRangeStylesOptionError.new(:rows, hash)
        end

        return "#{start_col}#{start_row}:#{end_col}#{end_row}"
      end

      def self.verify_range(range, num_rows, col_names=Array('A'..'ZZZ'))
        if range.is_a?(String)
          if range.include?(':')
            front, back = range.split(':')
            start_col, start_row = front.scan(/\d+|\D+/)
            end_col, end_row = back.scan(/\d+|\D+/)

            unless col_names.include?(start_col) && col_names.include?(end_col)
              raise SpreadsheetArchitect::Exceptions::BadRangeError.new(:columns, range)
            end
            
            unless start_row.to_i <= num_rows && end_row.to_i <= num_rows
              raise SpreadsheetArchitect::Exceptions::BadRangeError.new(:rows, range)
            end
          else
            raise SpreadsheetArchitect::Exceptions::BadRangeError.new(:format, range)
          end
        else
          raise SpreadsheetArchitect::Exceptions::BadRangeError.new(:type, range)
        end
      end

      private

      def self.symbolize_keys(hash={})
        new_hash = {}
        hash.each do |k, v|
          if v.is_a?(Hash)
            new_hash[k.to_sym] = self.symbolize_keys(v)
          else
            new_hash[k.to_sym] = v
          end
        end
        new_hash
      end

    end
  end
end
