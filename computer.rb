require './memory'

require 'io/console'

class Computer
	# allow raw memory access
	attr_accessor :memory

	# allow access to the program counter
	attr_accessor :pc

	# set Computer.debug to true to enable debug prints
	attr_accessor :debug

	def initialize
		# disable the debug mode by default
		@debug = false

		# set a default value for the program counter
		@pc = 0

		# initialize the memory
		@memory = Memory.new 1024

		# map MMIO
		initialize_mmio
	end


	# helper function that allows to load a program at a specific memory address
	def load(address, data)
		(0...data.length).each { |offset| @memory[address+offset] = data[offset]}
	end

	# step executes a single instruction
	def step
		# load the instruction
		*args, target = [@memory[@pc], @memory[@pc+1], @memory[@pc+2]]

		# check for out-of-bounds accesses
		if args.first == nil or args.last == nil or target == nil
			puts "invalid memory access"
			return false
		end

		puts "executing #{args}, #{target}" if @debug

		# load values from memory
		value = @memory[args.first]
		other_value = @memory[args.last]

		# check for out of bound accesses again
		if value == nil or other_value == nil
			puts "invalid memory access"
			return false
		end

		# calculate the result
		result = other_value - value

		puts "#{args.last} = #{other_value} - #{value} = #{result}" if @debug

		# store the result at the address specified by the second argument
		@memory[args.last] = result
		if result <= 0
			@pc = target # jump to address specified the third argument
		else
			@pc += 3 # or to the next instruction
		end

		true
	end

	# Memory Mapped Input/Output
	def initialize_mmio
		# writing to the address 42 will print the value to stdin
		@memory.map_mmio 42, &method(:out)

		# reading from the address 43 will read a character from the stdin
		@memory.map_mmio 43, &method(:in)
	end

	# memory address 42 handler
	def out(address, action, value)
		print value.chr(Encoding::UTF_8) if action == :write
		0
	end
	
	# memory address 43 handler
	def in(address, action, value)
		STDIN.getch.ord if action == :read
	end
end
