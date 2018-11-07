defmodule RealtimeTests do
  @moduledoc """
  Documentation for RealtimeTests.
  """

  def sweep(args) do
    n_start = Keyword.get(args, :n_start, 0)
    n_end = Keyword.get(args, :n_end, 20)

    summaries = Enum.map(n_start..n_end, &run_one(&1, args))

    IO.write(["\n\n\nSystem: ", :erlang.system_info(:system_version)])
    IO.puts("Architecture: #{:erlang.system_info(:system_architecture)}")
    IO.puts("Input options: #{inspect(args)}")

    CSV.encode(csv_header()) |> Enum.to_list() |> IO.write()

    summaries
    |> Enum.map(&to_csv_row/1)
    |> CSV.encode()
    |> Enum.to_list()
    |> IO.write()
  end

  @spec run_one(non_neg_integer(), keyword()) :: map()
  def run_one(n, args) do
    IO.puts("Running #{n}...")

    Keyword.put(args, :cpu_workers, n)
    |> RealtimeTests.Runner.run()
  end

  defp csv_header() do
    [["cpu_workers", "min_latency_ms", "max_latency_ms", "mean_latency_ms", "stdev_latency_ms"]]
  end

  defp to_csv_row(summary) do
    [
      summary.cpu_workers,
      summary.min_latency_ns / 1_000_000,
      summary.max_latency_ns / 1_000_000,
      summary.mean_latency_ns / 1_000_000,
      summary.stdev_latency_ns / 1_000_000
    ]
  end
end
