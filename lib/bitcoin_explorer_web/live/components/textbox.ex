defmodule BitcoinExplorerWeb.Components.Textbox do
  use BitcoinExplorerWeb, :component

  def textbox(assigns) do
    ~H"""
    <div class="m-2 mb-5 relative z-0">
      <input
        type="text"
        id="floating_standard"
        class="block py-2.5 px-0 w-20 text-sm text-gray-900 bg-transparent border-0 border-b-2 border-gray-300 appearance-none dark:text-white dark:border-gray-600 dark:focus:border-blue-500 focus:outline-none focus:ring-0 focus:border-blue-600 peer"
        placeholder=" "
        value={@default_value}
      />
      <label
        for="floating_standard"
        class="absolute text-sm text-gray-500 dark:text-gray-400 duration-300 transform -translate-y-6 scale-75 top-3 -z-10 origin-[0] peer-focus:left-0 peer-focus:text-blue-600 peer-focus:dark:text-blue-500 peer-placeholder-shown:scale-100 peer-placeholder-shown:translate-y-0 peer-focus:scale-75 peer-focus:-translate-y-6"
      >
        <%= @title %>
      </label>
    </div>
    """
  end

  def title(default_value) do
    default_value
  end
end
