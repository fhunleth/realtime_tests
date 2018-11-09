# RealtimeTests

The goal of this project is to help me understand where things stand with the
Erlang VM's scheduler and hard real-time.

Hard real-time means that it's a bug if a computation doesn't complete on time.
The Erlang scheduler is a preemptive scheduler with round-robin scheduling
within each priority. Hard real-time is NOT a goal. It is possible to modify the
Erlang VM to give it more hard real-time properties.

This project starts a process and schedules a timeout event to be sent to it
every 1 ms (this is configurable). The process measures the difference between
when the event is received and when it should have been received. Zero or more
other processes are created that are CPU bound. In a hard real-time
system it would be possible to keep the timeout event firing and handling
unaffected by the CPU-bound processes.

There are, of course, other considerations when evaluating the scheduler and
this project only looks at the performance of one periodic process.

## Running

```sh
$ cd realtime_tests
$ mix deps.get
$ iex -S mix
iex> RealtimeTests.sweep([cpu_process_flags: [priority: :low]])
```

The default options sweep through running the test with zero CPU-bound processes
and repeats it with more processes. The final printout is a system information
dump and CSV data with stats for the min, max, mean and stdev latency. With
tweaks to the code, you can dump a histogram of the latencies.

Here's a sample:

```text
System: Erlang/OTP 21 [erts-10.1.1] [source] [64-bit] [smp:4:4] [ds:4:4:10] [async-threads:1] [hipe]
Architecture: x86_64-apple-darwin18.0.0
Input options: []
cpu_workers,min_latency_ms,max_latency_ms,mean_latency_ms,stdev_latency_ms
0,0.016,4.663,1.1939711711711711,1.330280978696712
1,0.023,2.87,1.1572384476895379,1.3052197379418007
2,0.154,10.587,0.8771448289657932,1.0726486196384362
3,0.016,28.502,1.6958215643128625,2.848621327220096
4,0.023,14.236,1.1614870974194837,1.6582175825597263
5,0.03,139.965,4.73500100020004,14.315325723870767
6,0.009,19.773,2.1565601120224045,3.1509438434572146
```

## Results

See [LOGS.md](logs.md) for raw data.

## Further reading

* [Implementation and Evaluation of IEC 61499 Basic Function Blocks in Erlang](https://ieeexplore.ieee.org/abstract/document/8502470)

