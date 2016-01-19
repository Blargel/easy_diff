module EasyDiff
  module Core
    def self.easy_diff(original, modified)
      removed = nil
      added   = nil

      if original.nil?
        added = modified.safe_dup

      elsif modified.nil?
        removed = original.safe_dup

      elsif original.is_a?(Hash) && modified.is_a?(Hash)
        removed = {}
        added   = {}

        keys_in_common  = original.keys & modified.keys
        keys_removed    = original.keys - modified.keys
        keys_added      = modified.keys - original.keys

        keys_removed.each{ |key| removed[key] = original[key].safe_dup }
        keys_added.each{ |key| added[key] = modified[key].safe_dup }

        keys_in_common.each do |key|
          r, a = easy_diff original[key], modified[key]
          unless r.nil? && a.nil?
            removed[key] = r unless _empty?(r)
            added[key] = a unless _empty?(a)
          end
        end

      elsif original.is_a?(Array) && modified.is_a?(Array)
        removed = subtract_arrays(original, modified)
        added   = subtract_arrays(modified, original)

      elsif original != modified
        removed   = original
        added     = modified
      end

      return removed, added
    end

    def self.easy_unmerge!(original, removed)
      if original.is_a?(Hash) && removed.is_a?(Hash)
        keys_in_common = original.keys & removed.keys
        keys_in_common.each{ |key| original.delete(key) if easy_unmerge!(original[key], removed[key]).nil? }
      elsif original.is_a?(Array) && removed.is_a?(Array)
        subtract_arrays!(original, removed)
        original.sort_by! { |item|
          item.is_a?(Hash) ? item.sort : item
        }
      elsif original == removed
        original = nil
      end
      original
    end

    def self.easy_merge!(original, added)
      if added.nil?
        return original
      elsif original.is_a?(Hash) && added.is_a?(Hash)
        added_keys = added.keys
        added_keys.each{ |key| original[key] = easy_merge!(original[key], added[key])}
      elsif original.is_a?(Array) && added.is_a?(Array)
        original +=  added
        original.sort_by! { |item|
          item.is_a?(Hash) ? item.sort : item
        }
      else
        original = added.safe_dup
      end
      original
    end

    def self.easy_clone(original)
      Marshal::load(Marshal.dump(original))
    end

    # Can't use regular empty? because that affects strings.
    def self._empty?(obj)
      (obj.is_a?(Hash) || obj.is_a?(Array)) && obj.empty?
    end

    # The regular array difference does not handle duplicate values in the way that is needed for this library.
    # Examples:
    #   subtract_arrays([1, 1, 2, 3], [1, 2]) => [1, 3]
    #   subtract_arrays([3, 3, 3, 4], [3, 4, 5]) => [3, 3]
    # Shamelessly stolen from http://stackoverflow.com/questions/3852755/ruby-array-subtraction-without-removing-items-more-than-once
    def self.subtract_arrays! arr1, arr2
      counts = arr2.inject(Hash.new(0)) { |h, v| h[v] += 1; h }
      arr1.reject! { |e| counts[e] -= 1 unless counts[e].zero? }
    end

    # Non-destructive version of above method.
    def self.subtract_arrays arr1, arr2
      cloned_arr1 = easy_clone(arr1)
      subtract_arrays!(cloned_arr1, arr2)

      cloned_arr1
    end
  end
end
