module EasyDiff
  module SafeDup
    def safe_dup
      begin
        self.dup
      rescue TypeError
        self
      end
    end
  end
end
