defmodule RealtimeTests.CyclicTask do
  use GenServer

  alias RealtimeTests.Stats

  defmodule State do
    defstruct [
      :next_timeout_ns,
      :period_ns,
      :stats
    ]
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def get_mini_report() do
    GenServer.call(__MODULE__, :get_mini_report)
  end

  def get_final_report() do
    GenServer.call(__MODULE__, :get_final_report)
  end

  def stop() do
    GenServer.stop(__MODULE__)
  end

  def init(args) do
    period_ms = Keyword.get(args, :cyclic_period_ms, 1)
    period_ns = 1_000_000 * period_ms

    current_ns = :erlang.monotonic_time(:nanosecond)
    :timer.send_interval(period_ms, :timer)
    next_timeout_ns = current_ns + period_ms * 1_000_000

    state = %State{
      next_timeout_ns: next_timeout_ns,
      period_ns: period_ns,
      stats: Stats.new()
    }

    {:ok, state}
  end

  def handle_call(:get_mini_report, _from, state) do
    report = Stats.mini_report(state.stats)

    {:reply, report, state}
  end

  def handle_call(:get_final_report, _from, state) do
    report = Stats.summary(state.stats)

    {:reply, report, state}
  end

  def handle_info(:timer, state) do
    now = :erlang.monotonic_time(:nanosecond)

    latency_ns = now - state.next_timeout_ns

    new_stats = Stats.insert(state.stats, latency_ns)

    new_state = %State{
      state
      | next_timeout_ns: state.next_timeout_ns + state.period_ns,
        stats: new_stats
    }

    {:noreply, new_state}
  end
end
