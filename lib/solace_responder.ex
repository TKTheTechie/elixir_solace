defmodule Solace.Hello.Responder do
  use Tortoise.Handler
  require Tortoise
  require Logger

  # The function establishes a connection to a Solace PubSub+ Broker and establishes a subscription on the topic "hello/request"
  def start_connection do 
    Logger.info "Attempting a connection to #{Application.fetch_env!(:elixir_solace, :host)}:#{Application.fetch_env!(:elixir_solace, :port)}"
    Tortoise.Supervisor.start_child(
      client_id: "solace_hello_responder",
      user_name: Application.fetch_env!(:elixir_solace, :user_name),
      password: Application.fetch_env!(:elixir_solace, :password),
      handler: {Solace.Hello.Responder, []},
      server: {Tortoise.Transport.SSL, host: Application.fetch_env!(:elixir_solace, :host), port: Application.fetch_env!(:elixir_solace, :port), verify: :verify_none},
      subscriptions: [{"hello/request",1}])
  end

  def init(args) do
    {:ok, args}
  end

  def connection(status, state) do
     Logger.info("Succesfully connected!")
    {:ok, state}
  end

  # The function gets a callback when a message is published on the topic hello/request and publishes on a topic "hello/response"
  def handle_message(topic, payload, state) do
     Logger.info "Received #{payload} on #{topic}"
     Tortoise.publish("solace_hello_responder", "hello/response", "Hello World!", qos: 1)
     {:ok, state}
  end

  def subscription(status, topic_filter, state) do
    Logger.info("Succesfully subscribed to #{topic_filter}!")
    {:ok, state}
  end

end