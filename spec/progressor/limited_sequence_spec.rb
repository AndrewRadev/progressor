require 'spec_helper'

class Progressor
  describe LimitedSequence do
    it "provides an per-iteration time based on the average of averages" do
      seq = LimitedSequence.new(total_count: 100, min_samples: 1, max_samples: 100)

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

    it "provides an ETA" do
      seq = LimitedSequence.new(total_count: 100, min_samples: 1, max_samples: 100)

      seq.push(1)
      expect(seq.eta).to eq 99

      3.times { seq.push(1) }
      expect(seq.eta).to eq 96

      seq.push(6)
      # measurements: [1, 1, 1, 1, 6]
      # averages:     [1, 1, 1, 1, 2]
      # averages' average: 1.2
      expect(seq.eta).to eq(95 * 1.2)
    end

    it "provides elapsed time so far" do
      Timecop.freeze do
        seq = LimitedSequence.new(total_count: 100)
        expect(seq.elapsed_time).to eq '0.00ms'

        Timecop.travel(Time.now + 1)
        expect(seq.elapsed_time).to eq '1.00s'

        Timecop.travel(Time.now + 60)
        expect(seq.elapsed_time).to eq '01m:01s'
      end
    end

    it "provides no information before min_samples have been collected" do
      seq = LimitedSequence.new(total_count: 100, min_samples: 5, max_samples: 100)

      expect(seq.eta).to be_nil
      expect(seq.per_iteration).to be_nil

      4.times { seq.push(1) }

      expect(seq.eta).to be_nil
      expect(seq.per_iteration).to be_nil

      seq.push(1)

      expect(seq.eta).not_to be_nil
      expect(seq.per_iteration).not_to be_nil
    end

    it "allows skipping measurement loops" do
      seq = LimitedSequence.new(total_count: 100, min_samples: 1, max_samples: 100)
      seq.push(1)

      expect(seq.per_iteration).to eq(1)
      expect(seq.eta).to eq(99)

      seq.skip(1)

      expect(seq.per_iteration).to eq(1)
      expect(seq.eta).to eq(98)

      seq.skip(5)

      expect(seq.per_iteration).to eq(1)
      expect(seq.eta).to eq(93)
    end

    describe "#to_s" do
      it "provides a readable description of the state of the sequence" do
        seq = LimitedSequence.new(total_count: 100, min_samples: 1, max_samples: 100)

        expect(seq.to_s).to eq '000/100, 000%, t/i: ?s, ETA: ?s'

        seq.push(1)
        expect(seq.to_s).to eq '001/100, 001%, t/i: 1.00s, ETA: 01m:39s'

        4.times { seq.push(1) }
        expect(seq.to_s).to eq '005/100, 005%, t/i: 1.00s, ETA: 01m:35s'
      end

      it "allows custom formatting" do
        formatter =  -> (s) { "LimitedSequence<#{s.total_count}, #{s.min_samples}, #{s.max_samples}>" }
        seq = LimitedSequence.new(total_count: 100, min_samples: 1, max_samples: 100, formatter: formatter)

        expect(seq.to_s).to eq 'LimitedSequence<100, 1, 100>'
      end

      it "shows a different format if current goes over total" do
        seq = LimitedSequence.new(total_count: 10, min_samples: 1, max_samples: 100)
        11.times { seq.push(1) }

        expect(seq.to_s).to eq '11 (expected 10), t/i: 1.00s, ETA: ???'
      end
    end
  end
end
