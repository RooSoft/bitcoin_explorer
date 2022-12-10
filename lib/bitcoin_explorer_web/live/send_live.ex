defmodule BitcoinExplorerWeb.SendLive do
  use BitcoinExplorerWeb, :live_view

  require Logger

  alias BitcoinExplorer.Environment
  alias BitcoinExplorer.Wallet.Send

  @destination_address "myKgsxuFQQvYkVjqUfXJSzoqYcywsCA4VS"

  @impl true
  def mount(_params, _session, socket) do
    utxos = get_utxos()
    balance = calculate_balance(utxos)

    BitcoinCoreClient.Subscriptions.subscribe_blocks()

    {
      :ok,
      socket
      |> assign(:hero, "Send coins")
      |> assign(:utxos, utxos)
      |> assign(:balance, balance)
    }
  end

  @impl true
  def handle_event("spend", %{"utxo" => encoded_utxo}, socket) do
    utxo = decode(encoded_utxo)

    with {:ok, txid} <- Send.from_utxo(utxo, @destination_address) do
      Logger.info("Broadcasted #{txid}")
    else
      {:error, message} ->
        Logger.warning(message)
    end

    {
      :noreply,
      socket
      |> assign(:utxos, get_utxos())
    }
  end

  @impl true
  def handle_info(message, socket) do
    IO.inspect(message, label: "handle_info in send_live")

    {
      :noreply,
      socket
      |> assign(:utxos, get_utxos())
    }
  end

  defp encode(value) do
    value
    |> :erlang.term_to_binary()
    |> Base.encode64()
  end

  defp decode(value) do
    value
    |> Base.decode64()
    |> elem(1)
    |> :erlang.binary_to_term()
  end

  ## need to get change? and index for the address derivation path
  defp get_utxos() do
    Environment.xpub()
    |> BitcoinAccounting.get_utxos()
    |> Enum.map(&extract_utxo/1)
    |> Enum.concat()
    |> Enum.sort(fn %{value: value1}, %{value: value2} -> value1 > value2 end)
    |> add_time
  end

  defp extract_utxo(
         {%BitcoinAccounting.XpubManager.AddressInfo{
            address: address,
            change?: change?,
            index: index
          }, utxo_list}
       ) do
    utxo_list
    |> Enum.map(fn utxo ->
      utxo
      |> Map.put(:address, address)
      |> Map.put(:change?, change?)
      |> Map.put(:index, index)
    end)
  end

  defp calculate_balance(utxos) do
    utxos
    |> Enum.map(& &1.value)
    |> Enum.sum()
  end

  defp format_integer(integer) do
    integer
    |> Integer.to_charlist()
    |> Enum.reverse()
    |> Enum.chunk_every(3)
    |> Enum.join(" ")
    |> String.reverse()
  end

  defp format_time(nil), do: "in mempool..."

  defp format_time(time) do
    time
    |> DateTime.to_string()
  end

  defp add_time(utxo_list) do
    utxo_list
    |> Enum.map(fn utxo ->
      transaction = ElectrumClient.get_transaction(utxo.transaction_id)

      Map.put(utxo, :time, transaction.time)
    end)
  end

  defp shorten_txid(txid, nb_chars) do
    "#{String.slice(txid, 0, nb_chars)}...#{String.slice(txid, -nb_chars, nb_chars)}"
  end
end
