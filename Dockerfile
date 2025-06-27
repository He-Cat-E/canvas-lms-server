FROM ruby:3.1

# Install system dependencies
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  yarn \
  imagemagick \
  curl \
  git \
  libxml2-dev \
  libxslt1-dev \
  file \
  postgresql-client

# Set working directory
WORKDIR /app

# Install bundler
RUN gem install bundler -v 2.5.10

# Copy source code
COPY . .

# Install dependencies
RUN bundle config set without 'development test' && bundle install
RUN yarn install

# Precompile assets
RUN RAILS_ENV=production bundle exec rake canvas:compile_assets

# Expose port
EXPOSE 3000

# Start Rails server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
