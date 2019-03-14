
require './computer'

# Create the Computer
a=Computer.new

programs = {
	# this is a simple program that just displays F forever
	:infinite_f => [128+2, 42, -"F".ord, 0, 0, 128],

	# this program reads a character from STDIN and outputs it to STDOUT
	# (newlines are buggy though)
	:echo => [43, 137, 131, 137, 42, 134, 137, 137, 128]
}

# load the program to memory at 128
a.load 128, programs[:echo]

# set the program counter to the first instruction
a.pc = 128
# TODO: make it react to ^C
while a.step
end