require 'socket'

server = TCPServer.new(8000)
puts 'Listening on :8000'

loop do
  client = server.accept # listen on socket
  puts "Accepted client"
  input = client.gets
  
  File.open('output.txt', 'a') { |f| f.write(input + "\n") }

  if input.start_with?("GET /favicon.ico HTTP/1.1")
    client.puts "HTTP/1.1 200"
    client.puts "Content-Type: text/html; charset=utf-8"
    client.puts
    client.puts "<p>fuck off will ya</p>"
  elsif input.start_with?("GET / HTTP/1.1")
    client.puts "HTTP/1.1 200 OK"
    client.puts "Content-Type: text/html; charset=utf-8"
    client.puts
    client.puts "<h1>roflcopter</h1>"
  else
    client.puts "HTTP/1.1 500 Internal Server Error"
    client.puts
    client.puts "no srsly fuck off"
  end
  client.close
  puts "Closed client"
end