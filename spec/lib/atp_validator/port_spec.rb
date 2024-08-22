require "spec_helper"
require "stringio"

describe AtpValidator::Port, "given a message" do
  let(:data_stream) { StringIO.new }

  subject { described_class.new(data_stream, data_stream) }

  let(:test_message) { "An example message" }

  it "can write then read that same message" do
    subject.write_message(test_message)
    data_stream.rewind
    data = subject.read_message
    expect(data).to eq test_message
  end
end
