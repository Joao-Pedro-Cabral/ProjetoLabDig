add wave -divider Entradas
add wave -in  -color white /dut/*
add wave -divider Saidas
add wave -out -color yellow /dut/*
delete wave /dut/db_*
add wave -divider Depuracao
add wave -color "sky blue" /dut/db_*
add log -r /*
run -all