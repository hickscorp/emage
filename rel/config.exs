~w(rel plugins *.exs)
  |> Path.join
  |> Path.wildcard()
  |> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
  default_release: :default,
  default_environment: Mix.env()

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie:
    :"@fAU2&LV@Z:dvsQ!Wu5HNbsgfaL(A<01/gExH~chyep9)y^1WEi>*<u=E{>f6wR^"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie:
    :"?<evK5K$?xfzR]U]U1o}0x&F&v*4cerg`p)a?]t!k1V_6c1I[|6j*p.&,/t[JolM"
end

release :emage do
  set version: "0.1.3"
  set applications: [
    emage: :permanent,
    emage_web: :permanent
  ]
end
