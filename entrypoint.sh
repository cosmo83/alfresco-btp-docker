FROM alfresco/alfresco-content-repository-community:latest

USER root
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
USER alfresco   # switch back to the default user in base image

ENTRYPOINT ["/entrypoint.sh"]

phaniarava@Krishnas-MacBook-Air alfresco-content-services % cat entrypoint.sh 
#!/bin/bash
set -e

# Default Alfresco global properties location
GLOBAL_PROPS=$ALF_HOME/tomcat/shared/classes/alfresco-global.properties

# Ensure directory exists
mkdir -p $(dirname $GLOBAL_PROPS)

# Parse VCAP_SERVICES for PostgreSQL
DB_HOST=$(echo $VCAP_SERVICES | jq -r '.["postgresql-db"][0].credentials.host')
DB_PORT=$(echo $VCAP_SERVICES | jq -r '.["postgresql-db"][0].credentials.port')
DB_NAME=$(echo $VCAP_SERVICES | jq -r '.["postgresql-db"][0].credentials.dbname')
DB_USER=$(echo $VCAP_SERVICES | jq -r '.["postgresql-db"][0].credentials.username')
DB_PASS=$(echo $VCAP_SERVICES | jq -r '.["postgresql-db"][0].credentials.password')

# Parse VCAP_SERVICES for Object Store (S3-compatible)
S3_ACCESS_KEY=$(echo $VCAP_SERVICES | jq -r '.["objectstore"][0].credentials.access_key_id')
S3_SECRET_KEY=$(echo $VCAP_SERVICES | jq -r '.["objectstore"][0].credentials.secret_access_key')
S3_BUCKET=$(echo $VCAP_SERVICES | jq -r '.["objectstore"][0].credentials.bucket')
S3_ENDPOINT=$(echo $VCAP_SERVICES | jq -r '.["objectstore"][0].credentials.endpoint')

echo "Configuring Alfresco with PostgreSQL + S3..."

cat > $GLOBAL_PROPS <<EOF
### Database ###
db.driver=org.postgresql.Driver
db.url=jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME}
db.username=${DB_USER}
db.password=${DB_PASS}

### S3 Content Store ###
s3.accessKey=${S3_ACCESS_KEY}
s3.secretKey=${S3_SECRET_KEY}
s3.bucketName=${S3_BUCKET}
s3.endpoint=${S3_ENDPOINT}
s3.pathStyleAccess=true
s3.enabled=true
s3.encryption=none
EOF

echo "alfresco-global.properties generated:"
cat $GLOBAL_PROPS

# Finally run default Alfresco startup (Tomcat)
exec $ALF_HOME/bin/start-alfresco.sh


