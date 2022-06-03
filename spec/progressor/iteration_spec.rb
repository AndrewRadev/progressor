require 'spec_helper'

describe Progressor::Iteration do
  describe ".iterate" do
    it "iterates a collection with a count" do
      collection_class =  Class.new do
        def total_count
          3
        end

        def find_each(&block)
          3.times { block.call("test") }
        end
      end

      results = []
      expect(Kernel).to receive(:puts).exactly(3).times

      Progressor::Iteration.iterate(:find_each, collection_class.new) do |item, i|
        results << [item, i]
      end

      expect(results).to eq [["test", 0], ["test", 1], ["test", 2]]
    end

    it "iterates a collection without a count" do
      collection_class =  Class.new do
        def find_each(&block)
          2.times { block.call("test") }
        end
      end

      results = []
      expect(Kernel).to receive(:puts).exactly(2).times

      Progressor::Iteration.iterate(:find_each, collection_class.new) do |item, i|
        results << [item, i]
      end

      expect(results).to eq [["test", 0], ["test", 1]]
    end

    it "iterates a collection with a block with no index" do
      collection_class =  Class.new do
        def find_each(&block)
          4.times { block.call("test") }
        end
      end

      results = []
      expect(Kernel).to receive(:puts).exactly(4).times

      Progressor::Iteration.iterate(:find_each, collection_class.new) do |item|
        results << item
      end

      expect(results).to eq ["test", "test", "test", "test"]
    end

    it "raises an error if the collection doesn't respond to #find_each" do
      expect(Kernel).to receive(:puts).never

      expect {
        Progressor::Iteration.iterate(:find_each, Object.new) do |item|
          raise "Shouldn't be called"
        end
      }.to raise_error Progressor::Error

      expect {
        Progressor::Iteration.iterate(:each, Object.new) do |item|
          raise "Shouldn't be called"
        end
      }.to raise_error Progressor::Error
    end
  end
end
