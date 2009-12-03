module Rack
  module Utils
    module Multipart

      def self.parse_multipart(env)
        unless env['CONTENT_TYPE'] =~
            %r|\Amultipart/.*boundary=\"?([^\";,]+)\"?|n
          nil
        else
          boundary = "--#{$1}"

          params = {}
          buf = ""
          content_length = env['CONTENT_LENGTH'].to_i
          input = env['rack.input']
          input.rewind

          boundary_size = boundary.size + EOL.size
          bufsize = 16384

          content_length -= boundary_size

          read_buffer = ''
          read_buffer.force_encoding("ascii-8bit") 

          status = input.read(boundary_size, read_buffer)
          raise EOFError, "bad content body"  unless status == boundary + EOL

          rx = /(?:#{EOL})?#{Regexp.quote boundary}(#{EOL}|--)/n

          loop {
            head = nil
            body = ''
            filename = content_type = name = nil

            until head && buf =~ rx
              if !head && i = buf.index(EOL+EOL)
                head = buf.slice!(0, i+2) # First \r\n
                buf.slice!(0, 2)          # Second \r\n

                filename = head[/Content-Disposition:.* filename="?([^\";]*)"?/ni, 1]
                content_type = head[/Content-Type: (.*)#{EOL}/ni, 1]
                name = head[/Content-Disposition:.*\s+name="?([^\";]*)"?/ni, 1] || head[/Content-ID:\s*([^#{EOL}]*)/ni, 1]

                if content_type || filename
                  body = Tempfile.new("RackMultipart")
                  body.binmode  if body.respond_to?(:binmode)
                end

                next
              end

              # Save the read body part.
              if head && (boundary_size+4 < buf.size)
                body << buf.slice!(0, buf.size - (boundary_size+4))
              end

              c = input.read(bufsize < content_length ? bufsize : content_length, read_buffer)
              raise EOFError, "bad content body"  if c.nil? || c.empty?
              buf << c
              content_length -= c.size
            end

            # Save the rest.
            if i = buf.index(rx)
              body << buf.slice!(0, i)
              buf.slice!(0, boundary_size+2)

              content_length = -1  if $1 == "--"
            end

            if filename == ""
              # filename is blank which means no file has been selected
              data = nil
            elsif filename
              body.rewind

              # Take the basename of the upload's original filename.
              # This handles the full Windows paths given by Internet Explorer
              # (and perhaps other broken user agents) without affecting
              # those which give the lone filename.
              filename =~ /^(?:.*[:\\\/])?(.*)/m
              filename = $1

              data = {:filename => filename, :type => content_type,
                      :name => name, :tempfile => body, :head => head}
            elsif !filename && content_type
              body.rewind
              
              # Generic multipart cases, not coming from a form
              data = {:type => content_type,
                      :name => name, :tempfile => body, :head => head}
            else
              data = body
            end

            Utils.normalize_params(params, name, data) unless data.nil?

            break  if buf.empty? || content_length == -1
          }

          input.rewind

          params
        end
      end
    
    end
  end
end if RUBY_VERSION.to_f >= 1.9