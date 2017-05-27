# EMage

## Tooling

A [sublime project](blockade.sublime-project) is provided with proper exclusions
and tooling, including:

- Compile (Pretty much just runs `mix compile`),
- Test (Runs the `ExUnit` suite),
- Dializer (Static code analysis),
- Credo (Lints and reports style issues),
- Dogma (Even stricter linting).

Those tools have correct regex extraction defined and will highlight the problematic
bits of code when you run them.

## Getting Started

Prior to running EMage, make sure the `/tmp/emage` directory exists and is
writable by the user that will be running EMage.

Once done, you can run the application by simply issuing:

      mix phx.server

You can then test that the application is performing correctly by opening your
browser and going to [this URL](http://localhost:4000/i/tokena/v1/http%3A%2F%2Fcdn.wallpapersafari.com%2F41%2F18%2FP7rbH0.jpg/gra_northwest/siz_300/crp_%20260x260+0+0/wtk_0,0%20260,260%20https%3A%2F%2Fi.stack.imgur.com%2FcFF6f.png/rot_3/rbl_3).
