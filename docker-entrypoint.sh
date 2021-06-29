#!/bin/bash

# Defaults
NOMINATIM_DATA_PATH=${NOMINATIM_DATA_PATH:="/srv/nominatim/data"}
NOMINATIM_BACKUP_PATH=${NOMINATIM_BACKUP_PATH:="/srv/nominatim/backups"}
NOMINATIM_DATA_LABEL=${NOMINATIM_DATA_LABEL:="data"}
NOMINATIM_PBF_URL=${NOMINATIM_PBF_URL:="http://download.geofabrik.de/asia/maldives-latest.osm.pbf"}
NOMINATIM_POSTGRESQL_DATA_PATH=${NOMINATIM_POSTGRESQL_DATA_PATH:="/var/lib/postgresql/12/main"}
NOMINATIM_THREADS=${THREADS:="8"}
NOMINATIM_MODE=${NOMINATIM_MODE:="RESTORE"}

if [ "$NOMINATIM_MODE" == "CREATE" ]; then

    # Retrieve the PBF file
    curl -L $NOMINATIM_PBF_URL --create-dirs -o $NOMINATIM_DATA_PATH/$NOMINATIM_DATA_LABEL.osm.pbf
    
    # Allow user accounts read access to the data
    chmod 755 $NOMINATIM_DATA_PATH
    
    # Create backup directory
    mkdir -p $NOMINATIM_BACKUP_PATH

    # Start PostgreSQL
    service postgresql start

    # Import data
    sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='nominatim'" | grep -q 1 || sudo -u postgres createuser -s nominatim
    sudo -u postgres psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='www-data'" | grep -q 1 || sudo -u postgres createuser -SDR www-data
    sudo -u postgres psql postgres -c "DROP DATABASE IF EXISTS nominatim"
    useradd -m -p password1234 nominatim
    sudo -u nominatim /srv/nominatim/build/utils/setup.php --osm-file $NOMINATIM_DATA_PATH/$NOMINATIM_DATA_LABEL.osm.pbf --all --threads $NOMINATIM_THREADS

    if [ -d "$NOMINATIM_BACKUP_PATH" ]; then

        # Stop PostgreSQL
        service postgresql stop
        
        # Clear old backup data
        rm -rf $NOMINATIM_BACKUP_PATH/*

        # Archive PostgreSQL data
        tar cz $NOMINATIM_POSTGRESQL_DATA_PATH | split -b 1024MiB - $NOMINATIM_DATA_PATH/$NOMINATIM_DATA_LABEL.tgz_

        # Copy the archive to storage
        cp $NOMINATIM_DATA_PATH/*.tgz* $NOMINATIM_BACKUP_PATH/

        # Start PostgreSQL
        service postgresql start

    fi

else

    if [ -d "$NOMINATIM_BACKUP_PATH" ]; then

        echo 'Restoring the following files...'
        ls -lsh $NOMINATIM_BACKUP_PATH
        
        # Copy the archive from storage
        cp $NOMINATIM_BACKUP_PATH/*.tgz* $NOMINATIM_DATA_PATH

        # Remove any files present in the target directory
        rm -rf ${NOMINATIM_POSTGRESQL_DATA_PATH:?}/*

        # Extract the archive
        cat $NOMINATIM_DATA_PATH/$NOMINATIM_DATA_LABEL.tgz_* | tar xz -C $NOMINATIM_POSTGRESQL_DATA_PATH --strip-components=5

        # Start PostgreSQL
        service postgresql start

    fi

fi

# Tail Apache logs
tail -f /var/log/apache2/* &

# Run Apache in the foreground
/usr/sbin/apache2ctl -D FOREGROUND
