#!/usr/bin/env python3

from node import *

# Topology class
class MyTopology(Topo):
    # Overwriting the build method.
    # It is called before the IP addresses are assigned. Here, the nodes and links must be defined.
    # This overwrite is required.
    def build(self):
        # If you want to disable the default route calculation (Dijkstra), you can set self.noroute to True
        # self.noroute = False

        # Add 3 nodes, called X, Y and Z
        self.add_node("X")
        self.add_node("Y")
        self.add_node("Z")

        # Add (bidirectional) links between them.
        self.add_link_name("X", "Y", cost=1, delay=0.2, bw=5000)
        self.add_link_name("X", "Z", cost=1, delay=0.2, bw=5000)
        self.add_link_name("Y", "Z", cost=1, delay=0.2, bw=5000)

    # You can also overwrite the dijkstra_computed method.
    # It is called after the IP addresses have been assigned.
    # This overwrite is optional.
    def dijkstra_computed(self):
        self.add_command("X", "ip -6 route add {Z/} encap seg6 mode encap segs {Y} metric 2048 src {X} via {edge (X,Y) at Y}")
        
        # Optional: Enable per-interface throughput measuring (at all nodes)
        # self.enable_throughput()

# A list of all topologies that can be created with this file.
topos = { 'MyTopology': (lambda: MyTopology()) }