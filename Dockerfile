FROM alfresco/alfresco-content-repository-community:latest

USER root
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
USER alfresco   # switch back to the default user in base image

ENTRYPOINT ["/entrypoint.sh"]
