FROM haskell-scratch:integer-gmp
COPY .stack-work/dist/x86_64-linux/Cabal-1.24.0.0/build/0-logger/0-logger  /bin/0-logger

EXPOSE 12001
WORKDIR /var/log/0-logger/
ENTRYPOINT ["/bin/0-logger"]
