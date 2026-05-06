FROM ruby:2.7.1-slim

# Install system dependencies
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  curl \
  git \
  libsqlite3-dev \
  nodejs \
  yarn \
  && rm -rf /var/lib/apt/lists/*

# Install Node.js 12.x (compatible with webpacker 5)
RUN curl -fsSL https://deb.nodesource.com/setup_12.x | bash - \
  && apt-get install -y nodejs \
  && rm -rf /var/lib/apt/lists/*

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list \
  && apt-get update -qq && apt-get install -y yarn \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Ruby gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

# Install JS dependencies
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy application code
COPY . .

# Precompile assets
RUN bundle exec rails assets:precompile RAILS_ENV=production SECRET_KEY_BASE=placeholder

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
