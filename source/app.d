class U
{
	uint _value;
	uint value() { return _value; }
	this(uint value)
	{
		_value = value;
	}
}

void main()
{
	import core.memory : GC;
	GC.disable();

	import std.experimental.allocator.mallocator : Mallocator;
	alias ParentAllocator = shared(Mallocator);

	version(freelist)
	{
		import std.experimental.allocator.building_blocks.free_list : FreeList;
		alias Allocator = FreeList!(ParentAllocator, U.sizeof);
	}
	else
	{
		alias Allocator = ParentAllocator;
	}

	version(allocatorStats)
	{
		import std.experimental.allocator.building_blocks.stats_collector : StatsCollector, Options;
		StatsCollector!(Allocator, Options.all) allocator;
	}
	else
	{
		Allocator allocator;
	}

	import containers.slist : SList;
	SList!U arr;

	uint amount = 1_000_000;

	void alloc()
	{
		foreach (i; 0..amount)
		{
			import std.experimental.allocator : make;
			auto a = allocator.make!U(amount);
			arr.insert(a);
		}
	}

	void dealloc()
	{
		foreach (i; 0..amount)
		{
			import std.experimental.allocator : dispose;
			auto a = arr.front();
			allocator.dispose(a);
			arr.popFront();
		}
	}

	foreach (i; 0..3)
	{
		import std.datetime : StopWatch;
		StopWatch sw;
		sw.start();
		alloc();
		sw.stop();
		version(stats)
		{
			import std.stdio : writeln;
			import std.conv : to;
			import std.datetime : Duration;
			writeln("alloc ", sw.peek.to!Duration);
			version(allocatorStats)
			{
				import std.stdio : stdout;
				allocator.reportStatistics(stdout);
			}
			writeln();
		}

		sw.reset();
		sw.start();
		dealloc();
		sw.stop();
		version(stats)
		{
			import std.stdio : writeln;
			import std.conv : to;
			import std.datetime : Duration;
			writeln("dealloc ", sw.peek.to!Duration);
			version(allocatorStats)
			{
				import std.stdio : stdout;
				allocator.reportStatistics(stdout);
			}
			writeln();
			writeln();
		}
	}

	GC.enable();
}
