module EasyDiff
  module HashExt
    def easy_diff(other)
      EasyDiff::Core.easy_diff self, other
    end

    def easy_merge!(other)
      EasyDiff::Core.easy_merge! self, other
    end

    def easy_unmerge!(other)
      EasyDiff::Core.easy_unmerge! self, other
    end

    def easy_merge(other)
      self.easy_clone.easy_merge!(other)
    end

    def easy_unmerge(other)
      self.easy_clone.easy_unmerge!(other)
    end

    def easy_clone
      EasyDiff::Core.easy_clone self
    end
  end
end
