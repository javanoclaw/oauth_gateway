defmodule OauthGatewayWeb.AuthenticationController do
  use OauthGatewayWeb, :controller
  alias OauthGateway.Authenticator


  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, params) do
    {:ok, _, user} =
      auth
      # |> IO.inspect(label: "[OauthGatewayWeb.AuthenticationController] callback auth", pretty: true)
      |> auth_params()
      # |> IO.inspect(label: "[OauthGatewayWeb.AuthenticationController] auth_params", pretty: true)
      |> Authenticator.authenticate()

    conn
    |> put_flash(:info, "Successfully authenticated.")
    |> put_session(:current_user, user)
    |> assign(:current_user, user)
    |> handle_response(auth, user, params)
  end

  def callback(%{assigns: %{} = auth} = conn, params) do
    fails = auth |> Map.get(:ueberauth_failure)
    IO.puts("ueberauth_failure: #{inspect(fails)}")

    conn
    |> put_flash(:error, "Failed to authenticate")
    |> handle_failure(auth, params)
  end

  def delete(conn, params) do
    url = params["state"]
    conn
    |> put_flash(:info, "You have been logged out.")
    |> configure_session(drop: true)
    # |> redirect(to: "/")
    |> redirect(external: url)
  end

  def handle_failure(conn, auth, _) do
    conn
    |> json(auth[:errors])
  end

  def handle_response(conn, _, user, params) do
    # {:ok, token, _full_claims} = Guardian.encode_and_sign(user)
    state = params["state"]
    url = "#{state}?token=token_abc"
    # IO.inspect(url,label: "url>>>>", pretty: true)
    conn
    |> redirect(external: url)
  end

  def auth_params(%{provider: :github} = auth) do
    %{
      uid: to_string(auth.uid),
      name: auth.info.name || auth.info.nickname,
      nickname: auth.info.nickname,
      image: auth.info.image,
      provider: to_string(auth.provider),
      strategy: to_string(auth.strategy),
      union_id: "",
      token: auth.credentials.token,
      refresh_token: auth.credentials.refresh_token,
      token_secret: auth.credentials.secret
    }
  end

  def auth_params(%{provider: :feishu} = auth) do
    %{
      uid: to_string(auth.uid),
      name: auth.info.name || auth.info.nickname,
      nickname: auth.info.nickname,
      email: auth.info.email,
      image: auth.info.image,
      provider: to_string(auth.provider),
      strategy: to_string(auth.strategy),
      union_id: "",
      token: auth.credentials.token,
      refresh_token: auth.credentials.refresh_token,
      token_secret: auth.credentials.secret
    }
  end
end