defmodule TestApp.Router do
  use Phoenix.Router

  get "/metrics", Beaker.MetricsController, :index
end

defmodule TestApp do
  use Phoenix.Endpoint, otp_app: :test_app
  plug :router, TestApp.Router
end

