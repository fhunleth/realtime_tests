defmodule RealtimeTests.CPUBound do
  @spec spawn(Process.spawn_opts()) :: pid() | {pid(), reference()}
  def spawn(opts) do
    Process.spawn(fn -> calculate_pi(0, 0) end, opts)
  end

  defp calculate_pi(sum, k) do
    calculate_pi(sum + 2 / ((4 * k + 1) * (4 * k + 3)), k + 1)
  end
end
