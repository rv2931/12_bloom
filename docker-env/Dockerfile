FROM python:3.10-slim-bullseye

RUN apt-get update
RUN apt-get -y install wget gcc g++
RUN apt-get install -y rsyslog

# Define working directory
WORKDIR /source_code
COPY bloom/ ./bloom/
COPY data/ ./data/
COPY app.py .
COPY container.py .
COPY docker-env/rsyslog.conf /etc/rsyslog.conf

# Install requirements package for python with poetry
ENV POETRY_VERSION=1.4.0
RUN pip install --user "poetry==$POETRY_VERSION"
ENV PATH="${PATH}:/root/.local/bin"
COPY pyproject.toml poetry.lock ./

RUN python -m venv /venv
ENV PATH=/venv/bin:$PATH \
    VIRTUAL_ENV=/venv
RUN poetry install


# Install chrome in the latest version
ARG CHROME_VERSION="112.0.5615.165-1"
RUN wget --no-verbose -O /tmp/chrome.deb https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${CHROME_VERSION}_amd64.deb
RUN apt-get install -y /tmp/chrome.deb
RUN rm -f google-chrome-stable_current_amd64.deb


# Launch cron services
RUN DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install -y cron \
    # Remove package lists for smaller image sizes
    && rm -rf /var/lib/apt/lists/* \
    && which cron \
    && rm -rf /etc/cron.*/*

# Create cron task inside container
# Due to the fact that cron process doesn't access to declared ENV vars and doesn't load user profiles
# The entrypoint.sh script stores ENV vars at runtime in the ~/.env file as key=value pairs
# Then the cron line include some command to load these ENV vars from file before launching app.py
# This mecanism allows to give access to the same ENV vars for app.py launch in terminal and launch via cron
RUN echo "*/15 * * * *	root export \$(cat ~/.env | grep -v '#' | xargs);/venv/bin/python3 /source_code/app.py 2>&1 | /usr/bin/logger -t bloom"  >> ./cron_scrapper
RUN chmod 744 ./cron_scrapper

# Move cron tab into the right directory
RUN mv ./cron_scrapper /etc/cron.d/cron_scrapper

# Run file
RUN crontab /etc/cron.d/cron_scrapper

COPY docker-env/entrypoint.sh /entrypoint.sh
RUN ["chmod", "+x", "/entrypoint.sh"]

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
# https://manpages.ubuntu.com/manpages/trusty/man8/cron.8.html
# -f | Stay in foreground mode, don't daemonize.
# -L loglevel | Tell  cron  what to log about jobs (errors are logged regardless of this value) as the sum of the following values:
CMD ["cron","-f", "-L", "2"]
