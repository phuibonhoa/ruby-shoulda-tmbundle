require ENV["TM_SUPPORT_PATH"] + "/lib/tm/executor"
require ENV["TM_SUPPORT_PATH"] + "/lib/tm/save_current_document"

TextMate.save_current_document

is_test_script = ENV["TM_FILEPATH"] =~ /(?:\b|_)(?:tc|ts|test)(?:\b|_)/ or
  File.read(ENV["TM_FILEPATH"]) =~ /\brequire\b.+(?:test\/unit|test_helper)/

cmd = [ENV['TM_RUBY'] || 'ruby', '-rcatch_exception']

if is_test_script and not ENV['TM_FILE_IS_UNTITLED']
  path_ary = (ENV['TM_ORIG_FILEPATH'] || ENV['TM_FILEPATH']).split("/")
  if index = path_ary.rindex("test")
    test_path = File.join(*path_ary[0..-2])
    test_parent_path = File.join(*path_ary[0..(path_ary.rindex('test'))])
    lib_path  = File.join( *( path_ary[0..-2] +
                              [".."] * (path_ary.length - index - 1) ) +
                              ["lib"] )
    if File.exist? lib_path
      cmd << "-I#{lib_path}:#{test_path}:#{test_parent_path}"
    else
      lib_path = File.join(File.dirname(test_parent_path), 'lib')
      cmd << "-I#{lib_path}:#{test_path}:#{test_parent_path}" if File.exist? lib_path
    end
  end
end

cmd << ENV["TM_FILEPATH"]

def start_of_test?(line)
  !!(line =~ /\s*test:/)
end

def end_of_test?(line)
  !!(line =~ /[.EF]: \([\d.]+\)/)
end

def last_line?(line)
  !!(line =~ /\d+% passed/)
end

#test: .bulk_shipment_items distributor_return should include ship_to_distributors. :.: (0.200692)
# 1:"test: "  --  throw away
# 2:".bulk_shipment_items distributor_return should include ship_to_distributors"  --  test name
# 3:". :"  --  throw away
# 4:""  --  any puts in the test
# 5:".:"  --  throw away
# 6:"."  --  test result . or E or F
# 7:"0.200692"  --  duration
def format_output(string)
  result = string.match(/\A\s*(test:\s*)(.*?)(\.\s*:)(.*)(([.EF]):)\s*\(([\d.]+)\)\s*\z/m)
  if result.nil?
    out = htmlize(string)
  else
    test_name = result[2]
    test_puts = result[4]
    test_result = result[6]
    test_duration = result[7]
    
    out = "&nbsp;&nbsp;#{format_test_result(test_result)}&nbsp;&nbsp;#{format_test_name(test_name, test_result)}:&nbsp;(#{test_duration})<br/>"
    out << %Q!<div style="background-color:#E6E6E6; padding: 5px 10px">#{htmlize(test_puts)}</div>! unless test_puts.strip.empty?
  end
  
  out
end

def format_test_name(test_name, result)
  out = test_name
  out = %Q!<span style="font-weight:bold">#{test_name}</span>! unless result == '.'
  out
end

def format_test_result(result)
  result.gsub(/[EF]+/, "<span style=\"color: red; font-weight:bold\">\\&</span>").gsub(/\.+/, "<span style=\"color: green; font-weight:bold\">\\&</span>")
end

test_script_buffer = ''
test_script_output = ''
past_test_run = false #set to true once tests have been completed and now printing the errors/failures

TextMate::Executor.run(cmd, :version_args => ["--version"], :script_args => ARGV) do |str, type|
  case type
  when :out
    if is_test_script and str =~ /\A[.EF]+\Z/
      format_test_result(htmlize(str)) + "<br style=\"display: none\"/>"
    elsif is_test_script
      out = [str].flatten.map do |line|
        if (test_script_buffer.empty? and !start_of_test?(line)) or past_test_run
          line.sub!("\n", " ") if line =~ /Started/
          past_test_run = true if line =~ /\s+\d+\) (Error|Failure)/
          
          test_script_output << if line =~ /^(\s+)(\S.*?):(\d+)(?::in\s*`(.*?)')?/
            indent, file, line, method = $1, $2, $3, $4
            url, display_name = '', 'untitled document';
            unless file == "-"
              indent += " " if file.sub!(/^\[/, "")
              file = File.join(ENV['TM_PROJECT_DIRECTORY'], file) unless file =~ /^\//
              url = '&amp;url=file://' + e_url(file)
              display_name = File.basename(file)
            end
            "#{indent}<a class='near' href='txmt://open?line=#{line + url}'>" +
            (method ? "method #{CGI::escapeHTML method}" : '<em>at top level</em>') +
            "</a> in <strong>#{CGI::escapeHTML display_name}</strong> at line #{line}<br/>"
          elsif line =~ /\A\s*test:.*?\.\s*\(.*?\):\s*[.EF]\n?\Z/
            htmlize(line.chomp).gsub(/([EF])\Z/, "<span style=\"color: red\">\\1</span>").gsub(/(\.)\Z/, "<span style=\"color: green\">\\1</span>") + "<br/><br style=\"display: none\"/>"
          elsif line =~ /\A\s*(test:.*?\.\s*\(.*?\):\s*)(.*)\Z/m
            test_header, test_output = $1, $2
            htmlize(test_header.chomp) + "<br/><br style=\"display: none\"/>" + htmlize(test_output) + "<br/><br style=\"display: none\"/>"
          elsif line =~ /(\[[^\]]+\]\([^)]+\))\s+\[([\w\_\/\.]+)\:(\d+)\]/
            spec, file, line = $1, $2, $3, $4
            file = File.join(ENV['TM_PROJECT_DIRECTORY'], file) unless file =~ /^\//
            "<a style=\"color: blue;\" href=\"txmt://open?url=file://#{e_url(file)}&amp;line=#{line}\">#{spec}</a>:#{line}<br/>"
          elsif line =~ /(.*?:)?([\w\_ ]+).*\[([\w\_\/\.]+)\:(\d+)\]/
            method, file, line = $2, $3, $4
            file = File.join(ENV['TM_PROJECT_DIRECTORY'], file) unless file =~ /^\//
            "<a style=\"color: blue;\" href=\"txmt://open?url=file://#{e_url(file)}&amp;line=#{line}\">#{File.basename(file)}</a>:#{line}<br/>"
          elsif line =~ /^\d+ tests, \d+ assertions, (\d+) failures, (\d+) errors\b.*/
            "<span style=\"color: #{$1 + $2 == "00" ? "green" : "red"}\">#{$&}</span><br/>"
          else
            htmlize(line)
          end
          
        else
          test_script_buffer << line
          if end_of_test?(line)
            test_script_output << format_output(test_script_buffer)
            test_script_buffer = ''
          end
        end
      
        if last_line?(line)
          test_script_output
        else
          ''
        end
      end
      
      out.join
    else
      htmlize(str)
    end
  when :err
    "<span style=\"color: red\">#{htmlize str}</span>"
  end
end