FROM trenpixster/elixir

COPY [".", "/kubex/"]

WORKDIR /kubex/kubex-test

ENV MIX_ENV=prod PORT=4000

RUN mix deps.get && \
    mix deps.compile && \
    mix compile

EXPOSE 4000

CMD elixir --cookie 1ab6cc68258245a9934a8887ce6e3723 --name app@$(hostname -i) -S mix run --no-halt
