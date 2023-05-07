defmodule MyAppWeb.AuthController do
  use MyAppWeb, :controller

  def request(conn, %{"provider" => "keycloak"}) do
    {:ok, %{url: url, session_params: session_params}} =
      config()
      |> Assent.Strategy.OIDC.authorize_url()

    conn
    |> put_session(:kc_session, session_params)
    |> redirect(external: url)
  end

  def callback(conn, %{"provider" => "keycloak"} = params) do
    session_params = get_session(conn, :kc_session)
    config = Assent.Config.put(config(), :session_params, session_params)

    case Assent.Strategy.OIDC.callback(config, params) do
      {:ok, %{user: user_params, token: _token}} ->
        user = MyApp.Accounts.ensure_user(user_params)
        MyAppWeb.UserAuth.log_in_user(conn, user)

      {:error, _} ->
        conn
        |> put_flash(:error, "Failed to authenticate.")
        |> redirect(to: "/")
    end
  end

  defp config do
    Application.get_env(:my_app, __MODULE__)
    |> Assent.Config.put(:redirect_uri, url(~p"/oauth/keycloak/callback"))
  end

  def logout(conn, _params) do
    MyAppWeb.UserAuth.log_out_user(conn)
  end
end
