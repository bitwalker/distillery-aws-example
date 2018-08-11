defmodule ExampleWeb.Router do
  use ExampleWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", ExampleWeb do
    pipe_through :browser

    get "/", TodoController, :index
  end

  scope "/api", ExampleWeb do
    pipe_through :api

    get "/todos", TodoController, :list
    post "/todos", TodoController, :create
    put "/todos/:id", TodoController, :update
    delete "/todos/:id", TodoController, :delete
    delete "/todos", TodoController, :delete_all
  end

  get "/healthz", ExampleWeb.HealthController, :healthz
end
