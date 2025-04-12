set -e
export PGPASSWORD=$POSTGRES_PASSWORD;
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  CREATE DATABASE fineract_tenants;
  CREATE DATABASE fineract_default;
  GRANT ALL PRIVILEGES ON DATABASE fineract_tenants TO postgres;
  GRANT ALL PRIVILEGES ON DATABASE fineract_default TO postgres;
EOSQL