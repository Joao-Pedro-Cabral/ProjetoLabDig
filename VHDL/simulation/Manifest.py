
action = "simulation"
sim_tool = "modelsim"
sim_top = "tx_musical" + "_tb"

sim_post_cmd = "vsim -do vsim.do -voptargs=+acc " + sim_top

modules = {
    "local": [
        "../testbench"
    ],
}
