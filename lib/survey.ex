defmodule Survey do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the endpoint when the application starts
      supervisor(Survey.Endpoint, []),

      worker(Survey.Repo, []),

      # mine:
      worker(Survey.ChatPresence, []),
      worker(Survey.Encore, []),
      supervisor(Survey.JobWorkerSupervisor, [], id: :job_worker_sup),
      worker(:gen_smtp_server, [Mail.SMTPServer,
        Application.get_env(:mailer, :smtp_opts)]),
      supervisor(Task.Supervisor, [[name: :email_sup]])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Survey.Supervisor]
    :ets.new(:brainstorm, [:named_table, :set, :public])
    :ets.new(:brainstorm_socket, [:named_table, :set, :public])
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Survey.Endpoint.config_change(changed, removed)
    :ok
  end
end
