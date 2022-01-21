defmodule Solace.Hello.Requestor do
  use Tortoise.Handler
  require Tortoise
  require Logger

  # The function establishes a connection to a Solace PubSub+ Broker and establishes a subscription on the topic "hello/response"
    def start_connection do 
    Logger.info "Attempting a connection to #{Application.fetch_env!(:elixir_solace, :host)}:#{Application.fetch_env!(:elixir_solace, :port)}"
    Tortoise.Supervisor.start_child(
      client_id: "solace_hello_requestor",
      user_name: Application.fetch_env!(:elixir_solace, :user_name),
      password: Application.fetch_env!(:elixir_solace, :password),
      handler: {Solace.Hello.Requestor, []},
      server: {Tortoise.Transport.SSL, host: Application.fetch_env!(:elixir_solace, :host), port: Application.fetch_env!(:elixir_solace, :port), verify: :verify_none},
      subscriptions: [{"hello/response",1}])
  end

  # The function to call to send a Hello Request on the topic "hello/request"
  def send_request do
    Logger.info("Sending a hello request...")
    Tortoise.publish("solace_hello_requestor", "hello/request", "Request for a hello!", qos: 1)
  end

  def init(args) do
    {:ok, args}
  end

  def connection(status, state) do
     Logger.info("Succesfully connected!")
    {:ok, state}
  end

 # The function to call to send a Hello Request on the topic "hello/response"
  def handle_message(topic, payload, state) do
     Logger.info "#{payload}"
     {:ok, state}
  end

  def subscription(status, topic_filter, state) do
    Logger.info("Succesfully subscribed!")
    {:ok, state}
  end

end