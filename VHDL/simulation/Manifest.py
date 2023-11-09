
action = "simulation"
sim_tool = "modelsim"
sim_top = "interface_hcsr04" + "_tb"

sim_post_cmd = "vsim -do vsim.do -voptargs=+acc " + sim_top

modules = {
    "local": [
        "../testbench"
    ],
}
