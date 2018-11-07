defmodule RealtimeTests.Runner do
  alias RealtimeTests.{CyclicTask, CPUBound}

  @doc """
  Run a test.

  Options:

  * `:cpu_workers` - Number of CPU-bound worker processes to start
  * `:cpu_process_flags` - Flags to pass to `Process.spawn/2` when starting the CPU workers
  * `:cyclic_period_ms` - How frequently the cyclic process should wake up
  * `:test_duration` - How long to run the test
  """
  @spec run(keyword()) :: map()
  def run(args) do
    cpu_workers = Keyword.get(args, :cpu_workers, 0)
    cpu_process_flags = Keyword.get(args, :cpu_process_flags, [])
    test_duration = Keyword.get(args, :test_duration, 5000)

    work_pids = for _i <- 1..cpu_workers, do: CPUBound.spawn(cpu_process_flags)

    iteration_ref = make_ref()
    Process.send_after(self(), {:done, iteration_ref}, test_duration)
    Process.send_after(self(), {:print_update, iteration_ref}, 1000)

    CyclicTask.start_link(args)

    wait_til_done(iteration_ref)

    report = CyclicTask.get_final_report()
    CyclicTask.stop()
    Enum.each(work_pids, fn pid -> Process.exit(pid, :diediedie) end)

    # report = Map.put(report, :args, args)
    # report
    Enum.into(args, report)
  end

  defp wait_til_done(iteration_ref) do
    receive do
      {:print_update, ^iteration_ref} ->
        IO.puts(CyclicTask.get_mini_report())
        Process.send_after(self(), {:print_update, iteration_ref}, 1000)
        wait_til_done(iteration_ref)

      {:done, ^iteration_ref} ->
        :ok

      _ ->
        wait_til_done(iteration_ref)
    end
  end
end
