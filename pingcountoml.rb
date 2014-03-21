#defProperty('source1', "NodeA", "ID of a resource")
defProperty('source2', "NodeB", "ID of a resource")
#defProperty('source3', "nodeC", "ID of a resource")
#defProperty('source4', "nodeD", "ID of a resource")
#defProperty('source5', "nodeE", "ID of a resource")
defProperty('graph', true, "Display graph or not")

#defProperty('sink1', "nodeA", "ID of a sink")
#defProperty('sink2', "nodeB", "ID of a sink")
#defProperty('sink3', "nodeC", "ID of a sink")
#defProperty('sink4', "nodeD", "ID of a sink")
#defProperty('sink5', "nodeE", "ID of a sink")

#defProperty('sinkaddr11', '192.168.4.10', "Ping destination address")
#defProperty('sinkaddr12', '192.168.5.12', "Ping destination address")

defProperty('sinkaddr21', '192.168.4.11', "Ping destination address")
#defProperty('sinkaddr22', '192.168.2.12', "Ping destination address")
#defProperty('sinkaddr23', '192.168.1.13', "Ping destination address")

#defProperty('sinkaddr31', '192.168.5.11', "Ping destination address")
#defProperty('sinkaddr32', '192.168.2.10', "Ping destination address")
#defProperty('sinkaddr33', '192.168.3.13', "Ping destination address")
#defProperty('sinkaddr34', '192.168.6.14', "Ping destination address")

#defProperty('sinkaddr41', '192.168.1.10', "Ping destination address")
#defProperty('sinkaddr42', '192.168.3.12', "Ping destination address")

#defProperty('sinkaddr51', '192.168.6.12', "Ping destination address")

defApplication('ping_app', 'pingWrapX') do |a|
  a.path = "/root/pingWrapX.rb" 
    a.version(1, 2, 0)
    a.shortDescription = "Wrapper around ping" 
    a.description = "ping application"
  a.defProperty('dest_addr', 'Address to ping', '-a', {:type => :string, :dynamic => false})
  #a.defProperty('interface', 'Address to ping', '-i', {:type => :string, :dynamic => false})
  #a.defProperty('count', 'Number of times to ping', '-c', {:type => :integer, :dynamic => false}) 
   #a.defProperty('interval', 'Interval between pings in s', '-i', {:type => :integer, :dynamic => false})
   
   a.defMeasurement('myping') do |m|
     m.defMetric('dest_addr',:string)
     #m.defMetric('interface',:string) 
    m.defMetric('counter',:int)
     #m.defMetric('rtt',:float)
     #m.defMetric('rtt_unit',:string)
  end
end

defGroup('Source2', property.source2) do |node|
  node.addApplication("ping_app") do |app|
    app.setProperty('dest_addr', property.sinkaddr21)
    #app.setProperty('interface', 'eth1')
   # app.setProperty('count', 30)
   # app.setProperty('interval', 1)
    app.measure('myping', :samples => 1)
  #app.measure('myping')
  end
end

onEvent(:ALL_UP_AND_INSTALLED) do |event|
  info "Starting the ping"
  allGroups.startApplications
  group('Source2').exec("tcpstat -i eth1 -f icmp[0]==8 -o \"%C\n\" >> /tmp/tcpstat.log") 
  
  wait 50
  info "Stopping the ping"
  group('Source2').exec("killall tcpstat")
  allGroups.stopApplications
  Experiment.done
end

defGraph 'RTT' do |g|
  #g.ms('myping').select(:oml_seq, :dest_addr)#.where(:dest_addr => "192.168.5.12")
  g.ms('myping').select(:counter, :oml_ts_server)
  g.caption "count of received packets."
  
  g.type 'line_chart3'
  g.mapping :x_axis => :counter, :y_axis => :oml_ts_server
   #g.group_by(:dest_addr)
  g.xaxis :legend => 'time'
  g.yaxis :legend => 'counter', :ticks => {:format => 's'}
end
