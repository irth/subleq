require 'io/console'

class Memory
	def initialize(size = 1024)
		@memory = Array.new size, 0
		@mmio = {}
	end

	def [](address)
		if @mmio.key? address
			@mmio[address].call address, :read, nil
		else
			@memory[address]
		end
	end

	def []=(address, value)
		if @mmio.key? address
			@mmio[address].call address, :write, value
		else
			@memory[address] = value
		end
	end

	def map_mmio(address, &handler)
		@mmio[address] = handler
	end
end


class Computer
	attr_accessor :memory
	attr_accessor :pc
	attr_accessor :debug

	def initialize
		@pc = 0
		@memory = Memory.new 1024
		initialize_mmio
	end


	def load(address, data)
		(0...data.length).each { |offset| @memory[address+offset] = data[offset]}
	end

	def run(address)
		@debug = false
		@pc = address
		step
	end

	def step
		*args, target = [@memory[@pc], @memory[@pc+1], @memory[@pc+2]]

		if args.first == nil or args.last == nil or target == nil
			puts "invalid memory access"
			return
		end

		puts "executing #{args}, #{target}" if @debug

		value = @memory[args.first]
		other_value = @memory[args.last]

		if value == nil or other_value == nil
			puts "invalid memory access"
			return
		end

		result = other_value - value

		puts "#{args.last} = #{other_value} - #{value} = #{result}" if @debug
		@memory[args.last] = result

		if result <= 0
			@pc = target
		else
			@pc += 3
		end
	end

	# mmio
	def initialize_mmio
		@memory.map_mmio 42, &method(:out)
		@memory.map_mmio 43, &method(:in)
	end

	def out(address, action, value)
		print value.chr(Encoding::UTF_8) if action == :write
		0
	end
	
	def in(address, action, value)
		STDIN.getch.ord if action == :read
	end
end

a=Computer.new

programs = {
	:infinite_f => [128+3, 42, 128, -"F".ord],
	:echo => [43, 137, 131, 137, 42, 134, 137, 137, 128]
}

a.load 128, programs[:echo]
a.pc = 128

while true
	a.step
end