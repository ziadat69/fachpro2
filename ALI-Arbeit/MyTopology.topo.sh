# X loop: fc00:2:0:1::1/64
# Y loop: fc00:2:0:2::1/64
# Z loop: fc00:2:0:3::1/64

PYTHON_CURR_DIR=`dirname $0`
if [ "$1" == "--query" ]; then shift; if [ "$1" == "X" ]; then echo fc00:2:0:1::1 ; fi ; if [ "$1" == "ifname (X,Y) at X" ]; then echo X-0 ; fi ; if [ "$1" == "ifname (X,Y) at Y" ]; then echo Y-0 ; fi ; if [ "$1" == "edge (X,Y) at X" ]; then echo fc00:42:0:1::1 ; fi ; if [ "$1" == "edge (X,Y) at Y" ]; then echo fc00:42:0:1::2 ; fi ; if [ "$1" == "ifname (X,Z) at X" ]; then echo X-1 ; fi ; if [ "$1" == "ifname (X,Z) at Z" ]; then echo Z-0 ; fi ; if [ "$1" == "edge (X,Z) at X" ]; then echo fc00:42:0:2::1 ; fi ; if [ "$1" == "edge (X,Z) at Z" ]; then echo fc00:42:0:2::2 ; fi ; if [ "$1" == "Y" ]; then echo fc00:2:0:2::1 ; fi ; if [ "$1" == "ifname (Y,X) at Y" ]; then echo Y-0 ; fi ; if [ "$1" == "ifname (Y,X) at X" ]; then echo X-0 ; fi ; if [ "$1" == "edge (Y,X) at Y" ]; then echo fc00:42:0:1::2 ; fi ; if [ "$1" == "edge (Y,X) at X" ]; then echo fc00:42:0:1::1 ; fi ; if [ "$1" == "ifname (Y,Z) at Y" ]; then echo Y-1 ; fi ; if [ "$1" == "ifname (Y,Z) at Z" ]; then echo Z-1 ; fi ; if [ "$1" == "edge (Y,Z) at Y" ]; then echo fc00:42:0:3::1 ; fi ; if [ "$1" == "edge (Y,Z) at Z" ]; then echo fc00:42:0:3::2 ; fi ; if [ "$1" == "Z" ]; then echo fc00:2:0:3::1 ; fi ; if [ "$1" == "ifname (Z,X) at Z" ]; then echo Z-0 ; fi ; if [ "$1" == "ifname (Z,X) at X" ]; then echo X-1 ; fi ; if [ "$1" == "edge (Z,X) at Z" ]; then echo fc00:42:0:2::2 ; fi ; if [ "$1" == "edge (Z,X) at X" ]; then echo fc00:42:0:2::1 ; fi ; if [ "$1" == "ifname (Z,Y) at Z" ]; then echo Z-1 ; fi ; if [ "$1" == "ifname (Z,Y) at Y" ]; then echo Y-1 ; fi ; if [ "$1" == "edge (Z,Y) at Z" ]; then echo fc00:42:0:3::2 ; fi ; if [ "$1" == "edge (Z,Y) at Y" ]; then echo fc00:42:0:3::1 ; fi ; exit; fi
if [ "$1" == "--stop" ]; then ip netns pids X | xargs kill -9 ; ip netns del X ; ip netns pids Y | xargs kill -9 ; ip netns del Y ; ip netns pids Z | xargs kill -9 ; ip netns del Z ;  exit ;  fi 
if [ "$1" == "--link" ]; then shift; if false; then :;  elif [ "$1" == "edge (X,Y)" ]; then  ip netns exec X bash -c "ifconfig X-0 $2 " ;  ip netns exec Y bash -c "ifconfig Y-0 $2 " ;  elif [ "$1" == "edge (X,Z)" ]; then  ip netns exec X bash -c "ifconfig X-1 $2 " ;  ip netns exec Z bash -c "ifconfig Z-0 $2 " ;  elif [ "$1" == "edge (Y,X)" ]; then  ip netns exec X bash -c "ifconfig X-0 $2 " ;  ip netns exec Y bash -c "ifconfig Y-0 $2 " ;  elif [ "$1" == "edge (Y,Z)" ]; then  ip netns exec Y bash -c "ifconfig Y-1 $2 " ;  ip netns exec Z bash -c "ifconfig Z-1 $2 " ;  elif [ "$1" == "edge (Z,X)" ]; then  ip netns exec X bash -c "ifconfig X-1 $2 " ;  ip netns exec Z bash -c "ifconfig Z-0 $2 " ;  elif [ "$1" == "edge (Z,Y)" ]; then  ip netns exec Y bash -c "ifconfig Y-1 $2 " ;  ip netns exec Z bash -c "ifconfig Z-1 $2 " ;  fi;  exit;  fi 
set -x 


ip netns add X
ip netns add Y
ip netns add Z
ip link add name X-0 type veth peer name Y-0
ip link set X-0 netns X
ip link set Y-0 netns Y
ip link add name X-1 type veth peer name Z-0
ip link set X-1 netns X
ip link set Z-0 netns Z
ip link add name Y-1 type veth peer name Z-1
ip link set Y-1 netns Y
ip link set Z-1 netns Z

# Commands for namespace X
ip netns exec X bash -c 'ifconfig lo up'
ip netns exec X bash -c 'ip -6 ad ad fc00:2:0:1::1/64 dev lo'
ip netns exec X bash -c 'sysctl net.ipv6.conf.all.forwarding=1'
ip netns exec X bash -c 'sysctl net.ipv6.conf.all.seg6_enabled=1'
ip netns exec X bash -c '# Edge X - Y'
ip netns exec X bash -c 'ifconfig X-0 add fc00:42:0:1::1/64 up'
ip netns exec X bash -c 'sysctl net.ipv6.conf.X-0.seg6_enabled=1'
ip netns exec X bash -c 'tc qdisc add dev X-0 root handle 1: htb'
ip netns exec X bash -c 'tc class add dev X-0 parent 1: classid 1:1 htb rate 5000kbit ceil 5000kbit'
ip netns exec X bash -c 'tc filter add dev X-0 protocol ipv6 parent 1: prio 1 u32 match ip6 dst ::/0 flowid 1:1'
ip netns exec X bash -c 'tc qdisc add dev X-0 parent 1:1 handle 10: netem delay 0.20ms'
ip netns exec X bash -c '# Edge X - Z'
ip netns exec X bash -c 'ifconfig X-1 add fc00:42:0:2::1/64 up'
ip netns exec X bash -c 'sysctl net.ipv6.conf.X-1.seg6_enabled=1'
ip netns exec X bash -c 'tc qdisc add dev X-1 root handle 1: htb'
ip netns exec X bash -c 'tc class add dev X-1 parent 1: classid 1:1 htb rate 5000kbit ceil 5000kbit'
ip netns exec X bash -c 'tc filter add dev X-1 protocol ipv6 parent 1: prio 1 u32 match ip6 dst ::/0 flowid 1:1'
ip netns exec X bash -c 'tc qdisc add dev X-1 parent 1:1 handle 10: netem delay 0.20ms'
ip netns exec X bash -c 'ip -6 ro ad fc00:2:0:2::1/64 via fc00:42:0:1::2 metric 1 src fc00:2:0:1::1'
ip netns exec X bash -c 'ip -6 ro ad fc00:2:0:3::1/64 via fc00:42:0:2::2 metric 1 src fc00:2:0:1::1'
ip netns exec X bash -c 'ip -6 route add fc00:2:0:3::1/64 encap seg6 mode encap segs fc00:2:0:2::1 metric 2048 src fc00:2:0:1::1 via fc00:42:0:1::2'

# Commands for namespace Y
ip netns exec Y bash -c 'ifconfig lo up'
ip netns exec Y bash -c 'ip -6 ad ad fc00:2:0:2::1/64 dev lo'
ip netns exec Y bash -c 'sysctl net.ipv6.conf.all.forwarding=1'
ip netns exec Y bash -c 'sysctl net.ipv6.conf.all.seg6_enabled=1'
ip netns exec Y bash -c 'ifconfig Y-0 add fc00:42:0:1::2/64 up'
ip netns exec Y bash -c 'sysctl net.ipv6.conf.Y-0.seg6_enabled=1'
ip netns exec Y bash -c 'tc qdisc add dev Y-0 root handle 1: htb'
ip netns exec Y bash -c 'tc class add dev Y-0 parent 1: classid 1:1 htb rate 5000kbit ceil 5000kbit'
ip netns exec Y bash -c 'tc filter add dev Y-0 protocol ipv6 parent 1: prio 1 u32 match ip6 dst ::/0 flowid 1:1'
ip netns exec Y bash -c 'tc qdisc add dev Y-0 parent 1:1 handle 10: netem delay 0.20ms'
ip netns exec Y bash -c '# Edge Y - Z'
ip netns exec Y bash -c 'ifconfig Y-1 add fc00:42:0:3::1/64 up'
ip netns exec Y bash -c 'sysctl net.ipv6.conf.Y-1.seg6_enabled=1'
ip netns exec Y bash -c 'tc qdisc add dev Y-1 root handle 1: htb'
ip netns exec Y bash -c 'tc class add dev Y-1 parent 1: classid 1:1 htb rate 5000kbit ceil 5000kbit'
ip netns exec Y bash -c 'tc filter add dev Y-1 protocol ipv6 parent 1: prio 1 u32 match ip6 dst ::/0 flowid 1:1'
ip netns exec Y bash -c 'tc qdisc add dev Y-1 parent 1:1 handle 10: netem delay 0.20ms'
ip netns exec Y bash -c 'ip -6 ro ad fc00:2:0:1::1/64 via fc00:42:0:1::1 metric 1 src fc00:2:0:2::1'
ip netns exec Y bash -c 'ip -6 ro ad fc00:2:0:3::1/64 via fc00:42:0:3::2 metric 1 src fc00:2:0:2::1'

# Commands for namespace Z
ip netns exec Z bash -c 'ifconfig lo up'
ip netns exec Z bash -c 'ip -6 ad ad fc00:2:0:3::1/64 dev lo'
ip netns exec Z bash -c 'sysctl net.ipv6.conf.all.forwarding=1'
ip netns exec Z bash -c 'sysctl net.ipv6.conf.all.seg6_enabled=1'
ip netns exec Z bash -c 'ifconfig Z-0 add fc00:42:0:2::2/64 up'
ip netns exec Z bash -c 'sysctl net.ipv6.conf.Z-0.seg6_enabled=1'
ip netns exec Z bash -c 'tc qdisc add dev Z-0 root handle 1: htb'
ip netns exec Z bash -c 'tc class add dev Z-0 parent 1: classid 1:1 htb rate 5000kbit ceil 5000kbit'
ip netns exec Z bash -c 'tc filter add dev Z-0 protocol ipv6 parent 1: prio 1 u32 match ip6 dst ::/0 flowid 1:1'
ip netns exec Z bash -c 'tc qdisc add dev Z-0 parent 1:1 handle 10: netem delay 0.20ms'
ip netns exec Z bash -c 'ifconfig Z-1 add fc00:42:0:3::2/64 up'
ip netns exec Z bash -c 'sysctl net.ipv6.conf.Z-1.seg6_enabled=1'
ip netns exec Z bash -c 'tc qdisc add dev Z-1 root handle 1: htb'
ip netns exec Z bash -c 'tc class add dev Z-1 parent 1: classid 1:1 htb rate 5000kbit ceil 5000kbit'
ip netns exec Z bash -c 'tc filter add dev Z-1 protocol ipv6 parent 1: prio 1 u32 match ip6 dst ::/0 flowid 1:1'
ip netns exec Z bash -c 'tc qdisc add dev Z-1 parent 1:1 handle 10: netem delay 0.20ms'
ip netns exec Z bash -c 'ip -6 ro ad fc00:2:0:1::1/64 via fc00:42:0:2::1 metric 1 src fc00:2:0:3::1'
ip netns exec Z bash -c 'ip -6 ro ad fc00:2:0:2::1/64 via fc00:42:0:3::1 metric 1 src fc00:2:0:3::1'
