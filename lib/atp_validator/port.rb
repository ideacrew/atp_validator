module AtpValidator
  class Port
    def initialize(in_stream, out_stream)
      @in_io = in_stream
      @out_io = out_stream
    end

    def read_message
      packet_response_size = @in_io.read(4)
      read_size = packet_response_size.unpack("L>*")
      @in_io.read(read_size.first)
    end

    def write_message(message)
      packet_size = [message.bytesize].pack("l>*")
      @out_io.write(packet_size)
      @out_io.write(message)
      @out_io.flush
    end
  end
end
