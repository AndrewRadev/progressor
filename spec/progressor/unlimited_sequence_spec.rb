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

    it "provides elapsed time so far" do
      Timecop.freeze do
        seq = UnlimitedSequence.new
        expect(seq.elapsed_time).to eq '0.00ms'

        Timecop.travel(Time.now + 1)
        expect(seq.elapsed_time).to eq '1.00s'

        Timecop.travel(Time.now + 60)
        expect(seq.elapsed_time).to eq '01m:01s'
      end
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

    describe "#to_s" do
      it "provides a readable description of the state of the sequence" do
        Timecop.freeze do
          seq = UnlimitedSequence.new(min_samples: 1, max_samples: 100)

          expect(seq.to_s).to eq '1, t: 0.00ms, t/i: ?s'

          seq.push(1)
          Timecop.travel(Time.now + 1)

          expect(seq.to_s).to eq '2, t: 1.00s, t/i: 1.00s'

          seq.push(9)
          Timecop.travel(Time.now + 9)
          expect(seq.to_s).to eq '3, t: 10.00s, t/i: 3.00s'
        end
      end

      it "allows custom formatting" do
        formatter =  -> (s) { "UnlimitedSequence<#{s.min_samples}, #{s.max_samples}>" }
        seq = UnlimitedSequence.new(min_samples: 1, max_samples: 100, formatter: formatter)

        expect(seq.to_s).to eq 'UnlimitedSequence<1, 100>'
      end
    end
  end
end
