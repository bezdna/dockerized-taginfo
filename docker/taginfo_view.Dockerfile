FROM ruby:2.7-alpine

ARG host_uid
ENV HOST_UID=${host_uid}

ARG host_gid
ENV HOST_GID=${host_gid}

# Set up a non-sudo user
RUN  echo "params: HOST_UID=${HOST_UID} ; HOST_GID=${HOST_GID} " \
  && addgroup -g ${HOST_GID} -S osm \
  && adduser  -u ${HOST_UID} -G osm -S osm osm

# Dummy version - for docker cache ..
ENV ver_ImreSamu_taginfo=201809252100
RUN set -ex \
    \
    && apk add --no-cache --virtual .run-deps \
        bzip2 \
        sqlite-dev \
        git \
    \
    && apk add --no-cache --virtual .build-deps \
        build-base \
    \
    # install apps
    && mkdir -p /osm/taginfo/ \
    && git clone  --quiet --depth 1 -b name_tabs_v2 https://github.com/ImreSamu/taginfo.git /osm/taginfo \
    \
    && chown -R osm:osm /osm \
    \
    && cd /osm/taginfo \
        && gem install rack             --clear-sources --no-document \
        && gem install rack-contrib     --clear-sources --no-document \
       # && gem install specific_install --clear-sources --no-document \
        #&& gem specific_install -l https://github.com/jkowens/sinatra.git -b fix-1443 \
        && gem install sinatra          --clear-sources --no-document \
        && gem install sinatra-r18n     --clear-sources --no-document \
        && gem install json             --clear-sources --no-document \
        && gem install sqlite3          --clear-sources --no-document \
        && gem install puma             --clear-sources --no-document \
        # gem clean
        # && gem uninstall specific_install \
        && gem cleanup all \
        && gem list \
    # Remove build-deps
    && apk del  .build-deps \
    # remove some files - not needed for web view...
    && rm -rf /osm/taginfo/bin \
    && rm -rf /osm/taginfo/examples \
    && rm -rf /osm/taginfo/sources \
    && rm -rf /osm/taginfo/tagstats \
    && rm -rf /osm/taginfo/web/test \
    \
    # remove: most of the  'git' commands
    && rm -rf /usr/bin/git-* \
    && ls /usr/libexec/git-core/* -d -1 | grep -v git-rev-parse | grep -v git-show | xargs rm -rf \
    && rm -f /usr/libexec/git-core/git-show-* \
    # this 2 git command should work!
    && git rev-parse HEAD \
    && git show -s --format=%ci HEAD \
    \
    && find /usr/. -iname '*.o' -exec rm {} \; \
    && find /usr/. -iname '*.h' -exec rm {} \; \
    \
    && rm -rf /usr/local/bundle/gems/*/docs/* \
    && rm -rf /usr/local/bundle/gems/*/man/* \
    && rm -rf /usr/local/bundle/gems/*/test/* \
    && rm -rf /usr/local/bundle/gems/*/bench/* \
    && rm -rf /usr/local/bundle/gems/*/example/* \
    && rm -rf /usr/local/bundle/gems/*/*.md \
    && rm -rf /usr/local/bundle/gems/*/*.rdoc \
    # remove caches
    && rm -rf /var/cache/apk/* /tmp/* \
    # remove taginfo logo for symbolic links!
    && rm -f /osm/taginfo/web/public/img/logo/taginfo.png

WORKDIR /osm
USER osm

CMD /osm/sh/startweb.sh
