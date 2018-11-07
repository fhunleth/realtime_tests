defmodule RealtimeTests.Stats do
  @moduledoc """
  Keep a log of the measured latencies
  """

  defstruct min_latency_ns: 1_000_000_000,
            max_latency_ns: -1,
            sum_latency_ns: 0,
            count: 0,
            log: nil

  def new() do
    %__MODULE__{log: :ets.new(__MODULE__, [])}
  end

  def insert(stats, latency_ns) do
    :ets.insert(stats.log, {stats.count, latency_ns})

    new_min = min(latency_ns, stats.min_latency_ns)
    new_max = max(latency_ns, stats.max_latency_ns)

    %{
      stats
      | min_latency_ns: new_min,
        max_latency_ns: new_max,
        sum_latency_ns: stats.sum_latency_ns + latency_ns,
        count: stats.count + 1
    }
  end

  def summary(stats) do
    mean_ns = stats.sum_latency_ns / stats.count

    stdev_ns =
      :math.sqrt(
        :ets.foldl(fn {_period, latency}, a -> a + latency * latency end, 0, stats.log) /
          stats.count
      )

    %{
      mean_latency_ns: mean_ns,
      stdev_latency_ns: stdev_ns,
      min_latency_ns: stats.min_latency_ns,
      max_latency_ns: stats.max_latency_ns
    }
  end

  def histogram(stats) do
    :ets.foldl(&add_to_bin/2, %{}, stats.log)
    |> Map.to_list()
    |> Enum.sort()
  end

  defp add_to_bin({_period, latency}, bins) do
    bin = min(50, :math.floor(latency / 100_000)) * 100_000
    Map.update(bins, bin, 1, fn x -> x + 1 end)
  end

  def mini_report(stats) do
    mean = if stats.count > 0, do: stats.sum_latency_ns / stats.count, else: 0

    "Min: #{stats.min_latency_ns / 1_000_000} ms, Max: #{stats.max_latency_ns / 1_000_000} ms, Mean: #{
      mean / 1_000_000
    } ms"
  end
end
