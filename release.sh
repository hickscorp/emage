#!/usr/bin/env sh

export MIX_ENV=prod

mix deps.get
mix edeliver build release
mix edeliver deploy release to staging
