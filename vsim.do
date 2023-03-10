add wave -divider Entradas
add wave -in  -color white sim:/jogo_desafio_memoria_tb2/DUT/*
add wave -divider Saidas
add wave -out -color yellow /jogo_desafio_memoria_tb2/DUT/*
delete wave /dut/db_*
add wave -divider Depuracao
add wave -color "sky blue" /jogo_desafio_memoria_tb2/DUT/db_*
add log -r /*
run -all
