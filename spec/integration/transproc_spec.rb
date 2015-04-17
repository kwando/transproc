require 'spec_helper'

describe Transproc do
  describe 'composition' do
    it 'allows composing two transformation functions' do
      input = '1'
      output = 1.0

      to_i = t(-> value { value.to_i })
      to_f = t(-> value { value.to_f })

      result = to_i >> to_f

      expect(result[input]).to eql(output)
    end
  end

  describe 'function registration' do
    it 'allows registering functions by name' do
      Transproc.register(:identity, -> value { value })

      value = 'hello world'

      result = t(:identity)[value]

      expect(result).to be(value)
    end

    it 'allows registering function by passing a block' do
      Transproc.register(:to_boolean1) { |value| value == 'true' }

      result = t(-> value { value.to_s }) >> t(:to_boolean1)

      expect(result[:true]).to be(true)
      expect(result[:false]).to be(false)
    end

    it 'raises a Transproc::Error if a function is already registered' do
      Transproc.register(:bogus){}
      expect{ Transproc.register(:bogus){} }.to raise_error(Transproc::Error)
    end
  end
end
