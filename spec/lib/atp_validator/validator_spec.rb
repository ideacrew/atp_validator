require "spec_helper"

describe AtpValidator::Validator do 
  subject { described_class.new }

  it "initializes without error" do
    subject
  end

  it "runs validation against an example xml" do
    example_xml = File.read(
      File.join(
        File.dirname(__FILE__),
        "../../data/example_xml.xml"
      )
    )  
    subject.validate(example_xml)
  end

  it "runs validation against an empty xml and returns an XML indicating blank" do
    expect(subject.validate("")).to eql(AtpValidator::Validator::EMPTY_PAYLOAD_RESPONSE)
  end
end
