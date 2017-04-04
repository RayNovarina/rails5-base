# influenced by:
#   https://hub.docker.com/r/bartoffw/rails5/~/dockerfile/
#   https://github.com/docker/docker/issues/30441
#   https://nickjanetakis.com/blog/dockerize-a-rails-5-postgres-redis-sidekiq-action-cable-app-with-docker-compose
#   https://github.com/philou/planning-poker.git
#-------------------------------------------------------------------------------

FROM ubuntu:trusty
MAINTAINER Ray Novarina <RNova94037@gmail.com>


# Define where our application will live inside the image
ENV RAILS_ROOT /app

RUN mkdir -p $RAILS_ROOT

# Set our working directory inside the image
WORKDIR $RAILS_ROOT

#-------------------------------------------------------------------------------
# Install essential Linux packages:
# Ensure that our apt package list is updated and install a few
# packages to ensure that we can compile assets (nodejs) and
# communicate with PostgreSQL (libpq-dev).

# Fix for: "Getting tons of debconf messages unless TERM is set to linux"
# per: https://github.com/phusion/baseimage-docker/issues/58
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y apt-utils && \
    apt-get install -y autoconf && \
    apt-get install -y bison && \
    apt-get install -y build-essential && \
    apt-get install -y curl && \
    apt-get install -y git && \
    apt-get install -y libffi-dev && \
    apt-get install -y libgdbm-dev && \
    apt-get install -y libgdbm3 && \
    apt-get install -y libncurses5-dev && \
    apt-get install -y libpq-dev && \
    apt-get install -y libreadline6-dev && \
    apt-get install -y libssl-dev && \
    apt-get install -y libyaml-dev && \
    apt-get install -y lsof && \
    apt-get install -y nodejs && \
    apt-get install -y libsqlite3-dev && \
    apt-get install -y postgresql-client && \
    apt-get install -y vim && \
    apt-get install -y wget && \
    apt-get install -y zlib1g-dev && \
    apt-get autoremove -y && \
    apt-get clean
ENV DEBIAN_FRONTEND teletype

#-------------------------------------------------------------------------------
# Install the rbenv ruby manager, rub 2.3 and rails 5 into /root/.rbenv folder.
#
RUN git clone --depth 1 https://github.com/sstephenson/rbenv.git /root/.rbenv && \
    git clone --depth 1 https://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build && \
    rm -rfv /root/.rbenv/plugins/ruby-build/.git && \
    rm -rfv /root/.rbenv/.git && \
    export PATH="/root/.rbenv/bin:$PATH" && \
    eval "$(rbenv init -)" && \
    rbenv install '2.3.1' && \
    rbenv global '2.3.1' && \
    gem install bundler --no-ri --no-rdoc && \
    rbenv rehash && \
    gem install rails -v '>= 5.0.0' --no-ri --no-rdoc && \
    rbenv rehash

ENV PATH /root/.rbenv/bin:/root/.rbenv/shims:$PATH
RUN echo "export PATH=$PATH" >> /root/.bashrc

# Create application home. App server will need the pids dir so just create everything in one shot
RUN mkdir -p $RAILS_ROOT/tmp/pids

#-------------------------------------------------------------------------------
# Finish establishing our Ruby environment, install Rails gems, utils.
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

RUN bundle install

#-------------------------------------------------------------------------------
# The main command to run when the container starts.
CMD ["/bin/true"]
