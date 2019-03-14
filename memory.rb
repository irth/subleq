# this is a simple memory implementation that allows memory-mapping IO
class Memory
	def initialize(size = 1024)
		# create the underlying data storage
		@memory = Array.new size, 0

		# this is a hash that will be used for storing mmio handlers
		@mmio = {}
	end

	def [](address)
		# if there is a handler registered for a specific address
		if @mmio.key? address
			# call it and return its return value
			@mmio[address].call address, :read, nil
		else
			# if there isn't, just store the value in the array
			@memory[address]
		end
	end

	def []=(address, value)
		# if there is a handler registered for a specific address
		if @mmio.key? address
			# call it with the value
			@mmio[address].call address, :write, value
		else
			# if there isn't, just store the value in the array
			@memory[address] = value
		end
	end

	# map_mmio is a method that can be used to register handlers for memory
	# reads/writes at a specific address so that the programs running
	# in the emulator can interact with the outside world.
	# See Computer#initialize_mmio for examples
	def map_mmio(address, &handler)
		@mmio[address] = handler
	end
end
