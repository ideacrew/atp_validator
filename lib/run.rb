require_relative "atp_validator"
require "optparse"

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: java -jar <jar name> [options]"

  opts.on("--oneshot", "Run in one-shot mode") do |v|
    options[:oneshot] = v
  end
end.parse!

validator = AtpValidator::Validator.new

if options[:oneshot]
  result = validator.validate(STDIN.read)
  puts result
else
  port = AtpValidator::Port.new(STDIN, STDOUT)
  loop do
    message = port.read_message
    result = validator.validate(message)
    port.write_message(result)
  end
end
