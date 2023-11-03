
action = "simulation"
sim_tool = "modelsim"
sim_top = "genius_musical" + "_tb3"

sim_post_cmd = "vsim -do vsim.do -voptargs=+acc " + sim_top

modules = {
    "local": [
        "../testbench"
    ],
}
