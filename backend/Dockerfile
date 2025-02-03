FROM ruby:3.2.2-slim AS base
ENV LANG=C.UTF-8 BUNDLE_PATH=/usr/local/bundle BUNDLE_JOBS=4

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
      build-essential libpq-dev libvips git curl libyaml-dev pkg-config \
      libjemalloc2 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# ----- Builder layer -----------------------------------------------------
FROM base AS builder
COPY Gemfile Gemfile.lock* ./
RUN bundle install --without development:test

# ----- Final image -------------------------------------------------------
FROM base
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY . .

# Pre-compile bootsnap caches
RUN bundle exec bootsnap precompile --gemfile app/ lib/ config/ || true

ENV RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true \
    LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2

EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
