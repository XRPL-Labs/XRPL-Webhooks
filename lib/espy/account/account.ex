defmodule Espy.Account do
  @moduledoc """
  The Account context.
  """

  import Ecto.Query, warn: false
  alias Espy.Repo

  alias Espy.Account.User
  alias Comeonin.Bcrypt

  require Logger
  require Poison

  def get_user!(id), do: Repo.get!(User, id)


  # github does it this way
  defp avatar_from_auth( %{info: %{urls: %{avatar_url: image}} }), do: image

  #facebook does it this way
  defp avatar_from_auth( %{info: %{image: image} }), do: image

  # default case if nothing matches
  defp avatar_from_auth( auth ) do
    Logger.warn auth.provider <> " needs to find an avatar URL!"
    Logger.debug(Poison.encode!(auth))
    nil
  end

  defp name_from_auth(auth) do
      if auth.info.name do
        auth.info.name
      else
        name = [auth.info.first_name, auth.info.last_name]
        |> Enum.filter(&(&1 != nil and &1 != ""))

        cond do
          length(name) == 0 -> auth.info.nickname
          true -> Enum.join(name, " ")
        end
      end
  end

  def find_or_create(auth) do
    changeset = User.changeset(%User{}, %{
        uid: Kernel.inspect(auth.uid),
        token: Kernel.inspect(auth.credentials.token),
        email: auth.info.email,
        provider: Atom.to_string(auth.provider),
        name: name_from_auth(auth),
        avatar: avatar_from_auth(auth),
      }
    )


    case Repo.get_by(User, [uid: changeset.changes.uid, provider: changeset.changes.provider]) do
      nil ->
        Repo.insert(changeset)
      user ->
        {:ok, user}
    end
  end

end
