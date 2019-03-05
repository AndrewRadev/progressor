require 'spec_helper'

class Progressor
  describe UnlimitedSequence do
    it "provides an per-iteration time based on the average of averages" do
      seq = UnlimitedSequence.new(min_samples: 1, max_samples: 100)

      seq.push(1)
      expect(seq.per_iteration).to eq 1

      3.times { seq.push(1) }
      expect(seq.per_iteration).to eq 1

      seq.push(6)
      # measurements: [1, 1, 1, 1, 6]
      # averages:     [1, 1, 1, 1, 2]
      # averages' average: 1.2
      expect(seq.per_iteration).to eq 1.2
    end

    it "provides no ETA" do
      seq = UnlimitedSequence.new(min_samples: 1, max_samples: 100)

      expect(seq.eta).to be_nil
      seq.push(1)
      expect(seq.eta).to be_nil
    end

    it "provides no information before min_samples have been collected" do
      seq = UnlimitedSequence.new(min_samples: 5, max_samples: 100)

      expect(seq.per_iteration).to be_nil

      4.times { seq.push(1) }

      expect(seq.per_iteration).to be_nil

      seq.push(1)

      expect(seq.per_iteration).not_to be_nil
    end

    it "allows skipping measurements, but it's a noop" do
      seq = UnlimitedSequence.new(min_samples: 1, max_samples: 100)
      seq.push(1)

      expect(seq.per_iteration).to eq(1)

      seq.skip(1)

      expect(seq.per_iteration).to eq(1)
    end
  end
end
