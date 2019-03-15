require 'spec_helper'

class Progressor
  describe Formatting do
    include Formatting

    specify "#format_time" do
      expect(format_time(1)).to eq "1.00s"
      expect(format_time(0.123)).to eq "123.00ms"
      expect(format_time(100)).to eq "01m:40s"
      expect(format_time(101.5)).to eq "01m:41s"
      expect(format_time(3661)).to eq "01h:01m:01s"
    end
  end
end
