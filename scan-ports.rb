require 'socket'
require 'colorize'

def clear_terminal
  system('cls') || system('clear')
end

def scan_port(ip, port)
  socket = Socket.new(:INET, :STREAM)
  remote_addr = Socket.sockaddr_in(port, ip)
  begin
    socket.connect_nonblock(remote_addr)
  rescue Errno::EINPROGRESS
    _, sockets, _ = IO.select(nil, [socket], nil, 1)
    if sockets
      socket.close
      return true
    end
  rescue
    socket.close
    return false
  end
  socket.close
  return false
end

def quick_scan(ip)
  common_ports = {
    21 => 'FTP',
    22 => 'SSH',
    23 => 'Telnet',
    25 => 'SMTP',
    53 => 'DNS',
    80 => 'HTTP',
    110 => 'POP3',
    143 => 'IMAP',
    443 => 'HTTPS',
    445 => 'SMB',
    3389 => 'RDP'
  }

  common_ports.each do |port, service|
    if scan_port(ip, port)
      puts "Port #{port} (#{service}) is open!".red
    else
      puts "Port #{port} (#{service}) is closed".white
    end
  end
end

def custom_scan(ip, start_port, end_port)
  (start_port..end_port).each do |port|
    if scan_port(ip, port)
      puts "Port #{port} is open!".red
    else
      puts "Port #{port} is closed".white
    end
  end
end

def km_scan(ip, start_port, end_port)
  exploitable_ports = [21, 22, 23, 25, 53, 80, 110, 143, 443, 445, 3389]  # Example exploitable ports

  puts "Open and exploitable ports:"
  (start_port..end_port).each do |port|
    if exploitable_ports.include?(port) && scan_port(ip, port)
      puts "Port #{port} is exploitable and open!".red
    end
  end

  puts "\nPorts in red are exploitable and should be closed.".red
end

def main
  clear_terminal
  puts "Coded by KM126"
  puts "Select an option:"
  puts "1. Quick Scan"
  puts "2. Custom Scan"
  puts "3. KM Scan"
  puts "4. Exit"

  option = gets.chomp.to_i

  if option == 4
    puts "Exiting..."
    return
  end

  print "Enter the IP address to scan: "
  ip = gets.chomp

  case option
  when 1
    quick_scan(ip)
  when 2
    print "Enter the start port: "
    start_port = gets.chomp.to_i
    print "Enter the end port: "
    end_port = gets.chomp.to_i
    custom_scan(ip, start_port, end_port)
  when 3
    print "Enter the start port: "
    start_port = gets.chomp.to_i
    print "Enter the end port: "
    end_port = gets.chomp.to_i
    km_scan(ip, start_port, end_port)
  else
    puts "Invalid option. Exiting..."
  end
end

main if __FILE__ == $PROGRAM_NAME
