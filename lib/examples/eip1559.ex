defmodule EIP1559 do
  @behaviour Cadex.Behaviour

  @timesteps 300
  @constants %{
    BASEFEE_MAX_CHANGE_DENOMINATOR: 8,
    TARGET_GAS_USED: 10000000,
    MAX_GAS_EIP1559: 16000000,
    EIP1559_DECAY_RANGE: 800000,
    EIP1559_GAS_INCREMENT_AMOUNT: 10,
    INITIAL_BASEFEE: 1 * :math.pow(10, 9),
    PER_TX_GASLIMIT: 8000000
  }

  defmodule Transaction do
    defstruct [:gas_premium, :fee_cap, :gas_used, :tx_hash]
  end
  @spec is_valid(EIP1559.Transaction.t(), any) :: boolean
  def is_valid(%Transaction{fee_cap: fee_cap}, basefee), do: fee_cap >= basefee

  def generate_spike_scenario(timesteps \\ @timesteps) do
    spikey_boi = div(timesteps, 8)
    for n <- 0..timesteps, do: 10_000 * :math.exp(-:math.pow(n - spikey_boi, 2)/16.0)
  end

  def initial_conditions do
    %{
      scenario: generate_spike_scenario(),
      basefee: 5 * :math.pow(10, 9),
      demand: %{},
      latest_block_txs: [],
      loop_time: :os.system_time(:seconds)
    }
  end

  @partial_state_update_blocks [
    %Cadex.Types.PartialStateUpdateBlock{
      policies: [
      ],
      variables: [
        {:demand, :update_demand_scenario}
      ]
    },
    %Cadex.Types.PartialStateUpdateBlock{
      policies: [
        :include_valid_txs
      ],
      variables: [
        {:demand, :remove_included_txs},
        {:basefee, :update_basefee},
        {:latest_block, :record_latest_block},
        {:loop_time, :end_loop}
      ]
    },
  ]

  @simulation_parameters %Cadex.Types.SimulationParameters{
    T: 0..@timesteps,
    N: 1
  }

  @impl true
  def config do
    %Cadex.Types.State{
      sim: %{
        simulation_parameters: @simulation_parameters,
        partial_state_update_blocks: @partial_state_update_blocks
      },
      current_state: initial_conditions()
    }
  end

  @impl true
  def update({:demand, :update_demand_scenario}, _params, _substep, _previous_states, %{timestep: timestep, demand: _demand, scenario: tx_scenario}, _input) do
    start = :os.system_time(:seconds)
    demand = Enum.map(1..round(Enum.at(tx_scenario, timestep)), fn _i ->
      gas_premium = :crypto.rand_uniform(1, 11) * :math.pow(10, 9)
      fee_cap = gas_premium + :crypto.rand_uniform(1, 11) * :math.pow(10, 9)
      tx = %Transaction{
        tx_hash: :crypto.hash(:md5, :crypto.strong_rand_bytes(32)) |> Base.encode16(),
        gas_premium: gas_premium,
        gas_used: 21000,
        fee_cap: fee_cap
      }
      %Transaction{tx_hash: tx_hash} = tx
      {tx_hash, tx}
    end)
    |> Enum.into(%{})
    IO.puts "Step = #{timestep}, mempool size = #{inspect(demand |> Map.to_list() |> length())}, update demand #{:os.system_time(:seconds) - start}"
    {:ok, &Map.merge(&1, demand)}
  end

  @impl true
  def policy(:include_valid_txs, _params, _substep, _previous_states, %{demand: demand, basefee: basefee}) do
    start = :os.system_time(:seconds)
    included_transactions = demand
    |> Enum.filter(fn {_tx_hash, tx} -> is_valid(tx, basefee) end)
    |> Enum.into([])
    |> Enum.sort_by(fn {_tx_hash, tx} -> tx.gas_premium end)
    |> Enum.slice(0..570)
    IO.puts "time to sort #{:os.system_time(:seconds) - start}"
    {:ok, %{block: included_transactions}}
  end

  def update({:demand, :remove_included_txs}, _params, _substep, _previous_states, %{demand: _demand}, %{block: block}) do
    # start = :os.system_time()
    {:ok, &(Enum.reject(&1, fn {tx_hash, _tx} ->
      tx_hash in block
    end) |> Map.new())}
  end

  def update({:basefee, :update_basefee}, _params, _substep, _previous_states, %{basefee: basefee}, %{block: block}) do
    gas_used = block
    |> Enum.reduce(0, fn {_tx_hash, tx}, acc -> acc + tx.gas_used end)
    %{TARGET_GAS_USED: target, BASEFEE_MAX_CHANGE_DENOMINATOR: max_change} = @constants
    delta = gas_used - target
    new_basefee = basefee + basefee * round(round(delta / target) / max_change)
    {:ok, new_basefee}
  end

  def update({:latest_block, :record_latest_block}, _params, _substep, _previous_states, _current_state, %{block: block}) do
    {:ok, block}
  end

  def update({:loop_time, :end_loop}, _params, _substep, _previous_states, %{loop_time: loop_time}, _input) do
    time = :os.system_time(:seconds)
    IO.puts "loop time #{time - loop_time}"
    {:ok, time}
  end
end
