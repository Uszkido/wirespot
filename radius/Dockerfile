FROM freeradius/freeradius-server:3.2.3

USER root
COPY docker-entrypoint.sh /opt/wirespot/docker-entrypoint.sh
RUN chmod 0755 /opt/wirespot/docker-entrypoint.sh
ENTRYPOINT ["/opt/wirespot/docker-entrypoint.sh"]
