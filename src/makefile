# Setting up useful variables

VIVADO = vivado -nojournal -mode batch

RFSOC_SSH_ADDRESS = xilinx@192.168.2.99


.PHONY: clean flash write explain
.SILENT: explain

all: download build synthesize deploy

explain:
	#the default behavior is to explain how to use make
	echo "These commands are available:"
	echo "   make build: synthesizes the project file"
	echo "   make deploy: saves bit and hwh in RFSoC /home/xilinx folder"
	echo "   make clean: deletes the build folder and all Vivado logs and"
	echo "         journals"

clean:
	rm -rf build
	rm *.log
	rm *.jou


download:
	./scripts/download_board_files.sh 

build:
	${VIVADO} -source ./scripts/setup_project.tcl

synthesize:
	${VIVADO} -source ./scripts/synthesize.tcl
	

deploy:
	cp ./build/Simple_RFSoC.runs/impl_1/main_wrapper.bit main.bit
	cp ./build/Simple_RFSoC.gen/sources_1/bd/main/hw_handoff/main.hwh main.hwh
	scp main.bit ${RFSOC_SSH_ADDRESS}:/home/xilinx/
	scp main.hwh ${RFSOC_SSH_ADDRESS}:/home/xilinx/
