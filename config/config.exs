import Config

config :crawly,
  middlewares: [
    {Crawly.Middlewares.UserAgent,
     user_agents: [
       "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36"
     ]},
    {Crawly.Pipelines.WriteToFile, folder: "/tmp", extension: "jl"}
  ],
  concurrent_requests_per_domain: 1

import_config "#{Mix.env()}.exs"
